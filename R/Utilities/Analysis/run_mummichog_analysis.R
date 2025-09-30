### Modular MetaboAnalystR Analysis
### Run MetaboAnalystR analysis directly on tibble data without CSV intermediate files

#' Run Complete Mummichog Analysis using MetaboAnalystR
#'
#' This function performs a complete mummichog pathway enrichment analysis using the
#' MetaboAnalystR package. It takes tibble input directly and bypasses CSV intermediate
#' files for a streamlined workflow.
#'
#' @param ttest_results A tibble containing t-test results with columns: Feature, p.value, mode, mz
#' @param analysis_name Character string for the analysis name (used in output file naming)
#' @param database Character string specifying the database ("hsa_mfn" or "hsa_kegg")
#' @param base_output_dir Character string for the base output directory path
#' @param ppm_tolerance Numeric value for mass tolerance in ppm (default: 5)
#' @param rt_units Character string specifying retention time units ("seconds" or "minutes", default: "seconds")
#' @param p_threshold Numeric value for fixed p-value threshold (default: 0.1, ignored if use_dynamic_pval=TRUE)
#' @param use_dynamic_pval Logical, whether to use dynamic p-value thresholds based on data distribution (default: TRUE)
#' @param pval_fraction Numeric, fraction of peaks to include when using dynamic thresholds (default: 0.1 for top 10%)
#'
#' @return A list containing pathway results, network data, and file paths
#'
#' @examples
#' # Using dynamic p-value threshold (recommended, matches web interface)
#' results <- run_mummichog_analysis(
#'   ttest_results = my_ttest_tibble,
#'   analysis_name = "nosev",
#'   database = "hsa_mfn",
#'   base_output_dir = "Outputs/mummichog/outputs",
#'   rt_units = "seconds",  # or "minutes" depending on your data
#'   use_dynamic_pval = TRUE,
#'   pval_fraction = 0.1  # Top 10% of peaks
#' )
#' 
#' # Using fixed p-value threshold with minutes for RT
#' results <- run_mummichog_analysis(
#'   ttest_results = my_ttest_tibble,
#'   analysis_name = "nosev", 
#'   database = "hsa_mfn",
#'   rt_units = "minutes",
#'   use_dynamic_pval = FALSE,
#'   p_threshold = 0.05
#' )
#'
#' @export
run_mummichog_analysis <- function(
  ttest_results,
  analysis_name,
  database = "hsa_mfn",
  output_base_dir = "../../Outputs/mummichog/outputs",
  ppm_tolerance = 5.0,
  rt_units = "seconds",  # "seconds" or "minutes"
  instrument_type = "mixed",
  adducts_included = "yes",
  rt_tolerance = NA,  # Will be auto-calculated by MetaboAnalystR (2% of RT range)
  p_threshold = 0.05,  # Only used if use_dynamic_pval = FALSE
  use_dynamic_pval = TRUE,  # Default to dynamic like web interface
  pval_fraction = 0.1,  # Top 10% of peaks (matches web interface default)
  min_pathway_size = 3,
  permutations = 100,
  create_network = TRUE,
  plot_width = 150,
  dpi = 150
) {
  
  # Load required libraries
  library(MetaboAnalystR)
  library(dplyr)
  
  # Setup database caching (internal)
  setup_database_cache <- function(database, cache_dir = "Databases/MetaboAnalystR") {
    # Create cache directory if it doesn't exist
    if (!dir.exists(cache_dir)) {
      dir.create(cache_dir, recursive = TRUE)
      cat("📁 Created database cache directory:", cache_dir, "\n")
    }
    
    # Define database file path
    db_filename <- paste0(database, ".qs")
    cached_db_path <- file.path(cache_dir, db_filename)
    
    # Check if database is already cached
    if (file.exists(cached_db_path)) {
      cat("✅ Using cached database:", basename(cached_db_path), "\n")
      return(cached_db_path)
    }
    
    # Download database if not cached
    db_url <- paste0("https://www.metaboanalyst.ca/resources/libs/mummichog/", db_filename)
    cat("⬇️  Downloading", database, "database (one-time setup)...\n")
    
    tryCatch({
      download.file(url = db_url, destfile = cached_db_path, method = "auto", quiet = FALSE)
      
      if (file.exists(cached_db_path) && file.size(cached_db_path) > 1000) {
        cat("✅ Database cached for future use:", basename(cached_db_path), "\n")
        return(cached_db_path)
      } else {
        stop("Download failed or file is too small")
      }
    }, error = function(e) {
      cat("⚠️  Cache download failed, MetaboAnalystR will download directly\n")
      return(NULL)
    })
  }
  
  # Setup database cache
  cached_db_path <- setup_database_cache(database)
  
  # Source network function
  if (create_network && !exists("prepare_custom_enrichnet")) {
    source("../Utilities/Analysis/build_network.R")
  }
  
  # Validate database
  if (!database %in% c("hsa_mfn", "hsa_kegg")) {
    stop("Database must be 'hsa_mfn' or 'hsa_kegg'")
  }
  
  # Validate rt_units
  if (!rt_units %in% c("seconds", "minutes")) {
    stop("rt_units must be 'seconds' or 'minutes'")
  }
  
  # Create analysis directory name
  db_name <- toupper(gsub("hsa_", "", database))
  analysis_dir <- file.path(output_base_dir, analysis_name, db_name)
  
  # Create output directories
  dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)
  cat("Created analysis directory:", analysis_dir, "\n")
  
  # Store original working directory
  original_wd <- getwd()
  
  # Create temporary CSV file for MetaboAnalystR
  temp_csv <- tempfile(fileext = ".csv")
  readr::write_csv(ttest_results, temp_csv)
  cat("Created temporary CSV for MetaboAnalystR analysis\n")
  
  # Change to analysis directory
  setwd(analysis_dir)
  
  tryCatch({
    # Initialize MetaboAnalystR analysis
    cat("Running", db_name, "analysis for", analysis_name, "...\n")
    
    # Build analysis pipeline with native RT handling
    mSet <- InitDataObjects("mass_all", "mummichog", FALSE, dpi) %>%
      SetPeakFormat("rmp")
    
    # Set RT inclusion using MetaboAnalystR approach (handle version compatibility)
    tryCatch({
      # Try the native .rt.included function first
      mSet <- .rt.included(mSet, rt_units)
    }, error = function(e) {
      # Fallback: Set RT inclusion manually if .rt.included not available
      cat("Using fallback RT configuration method\n")
      if (rt_units == "seconds") {
        mSet$dataSet$rt.included <- TRUE
        mSet$dataSet$rt.unit <- "second"
      } else if (rt_units == "minutes") {
        mSet$dataSet$rt.included <- TRUE  
        mSet$dataSet$rt.unit <- "minute"
      }
    })
    
    # Continue with instrument parameters (rt_tolerance will be auto-calculated)
    mSet <- mSet %>%
      UpdateInstrumentParameters(ppm_tolerance, instrument_type, adducts_included, 0.02, rt_tolerance) %>%
      Read.PeakListData(temp_csv) %>%
      SanityCheckMummichogData() %>%
      SetPeakEnrichMethod("mum", "v2")
    
    # Apply dynamic or fixed p-value threshold using native MetaboAnalystR functions
    actual_threshold <- NULL
    if (use_dynamic_pval) {
      cat("Applying dynamic p-value threshold (top", pval_fraction * 100, "% of peaks)...\n")
      tryCatch({
        # Try native MetaboAnalystR function
        mSet <- SetMummichogPvalFromPercent(mSet, pval_fraction)
        # Extract the actual threshold that was set
        actual_threshold <- mSet$dataSet$mummi.param$mummi.pval
      }, error = function(e) {
        # Fallback: Calculate dynamic threshold manually if function not available
        cat("Using fallback dynamic p-value calculation\n")
        p_values <- mSet$dataSet$mummi.proc[, "p.value"]
        p_values <- p_values[!is.na(p_values)]
        n_peaks <- floor(pval_fraction * length(p_values))
        sorted_p <- sort(p_values)
        dynamic_threshold <- sorted_p[min(n_peaks, length(sorted_p))]
        # Use predefined thresholds similar to web interface
        if (dynamic_threshold <= 0.001) {
          actual_threshold <<- 0.001
        } else if (dynamic_threshold <= 0.01) {
          actual_threshold <<- 0.01
        } else if (dynamic_threshold <= 0.05) {
          actual_threshold <<- 0.05
        } else {
          actual_threshold <<- 0.1
        }
        cat("Calculated dynamic threshold:", actual_threshold, "\n")
        mSet <- SetMummichogPval(mSet, actual_threshold)
      })
    } else {
      cat("Applying fixed p-value threshold:", p_threshold, "...\n")
      mSet <- SetMummichogPval(mSet, p_threshold)
      actual_threshold <- p_threshold
    }
    
    # Continue with analysis (with error handling for pathway enrichment)
    tryCatch({
      mSet <- mSet %>%
        PerformPSEA(database, "current", min_pathway_size, permutations) %>%
        PlotPeaks2Paths(paste0("metaboanalyst_", tolower(db_name), "_"), "png", dpi, width = NA)
    }, error = function(e) {
      if (grepl("invalid.*size", e$message)) {
        cat("⚠ Pathway analysis failed with 'invalid size' error. This may be due to:\n")
        cat("  - Too few significant peaks meeting the p-value threshold\n")
        cat("  - Pathway database connectivity issues\n")
        cat("  Trying alternative approach...\n")
        
        # Try with different parameters
        tryCatch({
          mSet <- PerformPSEA(mSet, database, "current", max(1, min_pathway_size - 1), max(10, permutations - 50))
          mSet <- PlotPeaks2Paths(mSet, paste0("metaboanalyst_", tolower(db_name), "_"), "png", dpi, width = NA)
        }, error = function(e2) {
          stop("Pathway analysis failed even with adjusted parameters: ", e2$message)
        })
      } else {
        stop("Pathway analysis error: ", e$message)
      }
    })
    
    cat("✓", db_name, "analysis completed successfully\n")
    
    # Report the actual p-value threshold that was used
    if (!is.null(actual_threshold)) {
      if (use_dynamic_pval) {
        cat("📊 Final p-value threshold used:", actual_threshold, "(calculated from top", pval_fraction * 100, "% of peaks)\n")
      } else {
        cat("📊 Fixed p-value threshold used:", actual_threshold, "\n")
      }
    }
    
    # Create custom network if requested
    if (create_network) {
      tryCatch({
        mSet <- prepare_custom_enrichnet(mSet, paste0("enrichNet_", tolower(db_name)), "mixed")
        cat("✓ Custom network analysis prepared for", db_name, "\n")
      }, error = function(e) {
        cat("⚠ Custom network analysis failed for", db_name, ":", e$message, "\n")
      })
    }
    
    # Clean up temporary file
    file.remove(temp_csv)
    
    # Return to original directory
    setwd(original_wd)
    
    # Summary
    cat("✓", db_name, "analysis complete for", analysis_name, "!\n")
    cat("Results saved in:", analysis_dir, "\n")
    
    return(list(
      mSet = mSet,
      analysis_name = analysis_name,
      database = database,
      output_dir = analysis_dir,
      success = TRUE
    ))
    
  }, error = function(e) {
    # Clean up on error
    if (file.exists(temp_csv)) file.remove(temp_csv)
    setwd(original_wd)
    
    cat("⚠ Error in", db_name, "analysis:", e$message, "\n")
    return(list(
      analysis_name = analysis_name,
      database = database,
      error = e$message,
      success = FALSE
    ))
  })
}
