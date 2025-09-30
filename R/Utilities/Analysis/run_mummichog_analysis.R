#' Run Mummichog Pathway Enrichment Analysis
#'
#' This function performs mummichog pathway enrichment analysis using MetaboAnalystR.
#' It takes tibble input, creates temporary CSV files, and runs the complete analysis
#' pipeline with configurable parameters.
#'
#' @param ttest_results A tibble containing t-test results with required columns
#' @param output_dir Character. Directory path where analysis results will be saved
#' @param database Character. Must be "hsa_kegg" or "hsa_mfn" for pathway database
#' @param instrumentOpt Numeric. Mass-spec instrument parameter (default: 5.0)
#' @param msModeOpt Character. Mass-spec mode (default: "mixed")
#' @param force_primary_ion Character. Primary ion filtering, "yes" or "no" (default: "yes")
#' @param rt_frac Numeric. RT fraction parameter (default: 0.02)
#' @param rt_tol Numeric. RT tolerance parameter (default: NA)
#' @param pval_peak_cutoff Logical. If TRUE, uses dynamic p-value threshold 
#'   to analyze top 10% of peaks. If FALSE (default), analyzes all peaks (p < 1.0)
#'
#' @return A MetaboAnalyst mSet object containing analysis results
#'
#' @examples
#' \dontrun{
#' # MFN database analysis
#' result <- run_mummichog_analysis(
#'   ttest_results = my_ttest_data,
#'   output_dir = "outputs/analysis_mfn",
#'   database = "hsa_mfn"
#' )
#' 
#' # KEGG database with custom parameters
#' result <- run_mummichog_analysis(
#'   ttest_results = my_ttest_data,
#'   output_dir = "outputs/analysis_kegg", 
#'   database = "hsa_kegg",
#'   instrumentOpt = 3.0,
#'   msModeOpt = "positive"
#' )
#' }
#'
#' @export
run_mummichog_analysis <- function(
  ttest_results, 
  output_dir, 
  database,  # Must be "hsa_kegg" or "hsa_mfn"
  instrumentOpt = 5.0,      # Numeric - mass-spec instrument 
  msModeOpt = "mixed",      # Character - mass-spec mode 
  force_primary_ion = "yes", # Character - primary ion filtering
  rt_frac = 0.02,           # RT fraction
  rt_tol = NA,              # RT tolerance
  pval_peak_cutoff = FALSE   # TRUE = dynamic top 10%, FALSE = use all peaks (1.0)
) {
  
  library(MetaboAnalystR)
  
  # FIRST: Create output directory and change to it immediately
  cat("Original working directory:", getwd(), "\n")
  cat("Trying to create output directory:", output_dir, "\n")
  
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
    cat("Created output directory:", output_dir, "\n")
  } else {
    cat("Output directory already exists:", output_dir, "\n")
  }
  
  # Check if directory actually exists
  if (dir.exists(output_dir)) {
    cat("✓ Directory confirmed to exist:", output_dir, "\n")
  } else {
    cat("✗ ERROR: Directory does not exist after creation attempt!\n")
    stop("Failed to create output directory")
  }
  
  original_wd <- getwd()
  setwd(output_dir)
  cat("Working directory changed to:", getwd(), "\n")
  cat("Files currently in this directory:", paste(list.files(), collapse = ", "), "\n")
  
  # Set up database caching to avoid re-downloading
  # Get the project root directory (go up from current working directory)
  project_root <- original_wd  # Use original working directory as project root
  while (!file.exists(file.path(project_root, "run.R")) && dirname(project_root) != project_root) {
    project_root <- dirname(project_root)
  }
  cache_dir <- file.path(project_root, "Databases")
  
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
    cat("Created database cache directory:", cache_dir, "\n")
  }
  
  # Set MetaboAnalyst to use cache directory
  if (exists(".on.public.web")) {
    .on.public.web <- FALSE  # Ensure local mode
  }
  
  # Validate database
  if (!database %in% c("hsa_kegg", "hsa_mfn")) {
    stop("Database must be 'hsa_kegg' or 'hsa_mfn'")
  }
  
  # Create temp CSV file (we're already in output directory)
  temp_csv <- "temp_input.csv"
  readr::write_csv(ttest_results, temp_csv)
  
  # Suppress common non-critical MetaboAnalystR warnings
  suppressWarnings({
    # EXACT WORKING SEQUENCE with configurable parameters
    mSet <- InitDataObjects("mass_all", "mummichog", FALSE, 150)
    
    # Check if mSet was properly initialized
    if (is.null(mSet) || !is.list(mSet)) {
      stop("Failed to initialize mSet object")
    }
    cat("✓ InitDataObjects completed\n")
    
    mSet <- SetPeakFormat(mSet, "rmp")
    if (!is.list(mSet)) stop("mSet corrupted after SetPeakFormat")
    cat("✓ SetPeakFormat completed\n")
    
    mSet <- UpdateInstrumentParameters(mSet, instrumentOpt, msModeOpt, force_primary_ion, rt_frac)
    if (!is.list(mSet)) stop("mSet corrupted after UpdateInstrumentParameters")
    cat("✓ UpdateInstrumentParameters completed\n")
    
    mSet <- Read.PeakListData(mSet, temp_csv)
    if (!is.list(mSet)) stop("mSet corrupted after Read.PeakListData")
    cat("✓ Read.PeakListData completed\n")
    
    mSet <- SanityCheckMummichogData(mSet)
    if (!is.list(mSet)) stop("mSet corrupted after SanityCheckMummichogData")
    cat("✓ SanityCheckMummichogData completed\n")
    
    mSet <- SetPeakEnrichMethod(mSet, "mum", "v2")
    if (!is.list(mSet)) stop("mSet corrupted after SetPeakEnrichMethod")
    cat("✓ SetPeakEnrichMethod completed\n")
    
    # P-value threshold selection
    if (pval_peak_cutoff) {
      # Custom implementation of SetMummichogPvalFromPercent (fixed version)
      fraction <- 0.1  # Top 10% of peaks
      peakFormat <- mSet$paramSet$peakFormat
      
      if(peakFormat %in% c("rmp", "rmt")){
        maxp <- 0
      } else {
        pvals <- c(0.25, 0.2, 0.15, 0.1, 0.05, 0.01, 0.005, 0.001, 0.0005, 0.0001, 0.00005, 0.00001)
        ndat <- mSet$dataSet$mummi.proc
        n <- floor(fraction * length(ndat[,"p.value"]))
        cutoff <- ndat[n+1,1]
        if(!any(pvals <= cutoff)){
          maxp <- 0.00001
        } else {
          maxp <- max(pvals[pvals <= cutoff])
        }
      }
      
      mSet$dataSet$cutoff <- maxp
      mSet <- SetMummichogPval(mSet, maxp)  # Fixed: pass mSet instead of NA
      cat("✓ Dynamic p-value threshold calculated:", maxp, "(top 10% of peaks)\n")
    } else {
      # Use all peaks
      mSet <- SetMummichogPval(mSet, 1.0)
      cat("✓ Using all peaks (p-value threshold: 1.0)\n")
    }
    
    if (!is.list(mSet)) stop("mSet corrupted after SetMummichogPval")
    
    mSet <- PerformPSEA(mSet, database, "current", 3, 100)
    if (!is.list(mSet)) stop("mSet corrupted after PerformPSEA")
    cat("✓ PerformPSEA completed\n")
    
    mSet <- PlotPeaks2Paths(mSet, "peaks_to_paths_0_", "png", 150, width=NA)
    if (!is.list(mSet)) stop("mSet corrupted after PlotPeaks2Paths")
    cat("✓ PlotPeaks2Paths completed\n")
    
    # DEBUG: Check what's in the current directory
    cat("=== DEBUGGING FILE CREATION ===\n")
    cat("Current working directory:", getwd(), "\n")
    created_files <- list.files(getwd(), full.names = FALSE)
    cat("Files in current directory:", paste(created_files, collapse = ", "), "\n")
    
    # Check if specific expected files exist
    expected_files <- c("scattermum.json", "peaks_to_paths_0_dpi150.png")
    for (f in expected_files) {
      if (file.exists(f)) {
        cat("✓ Found expected file:", f, "\n")
      } else {
        cat("✗ Missing expected file:", f, "\n")
      }
    }
    cat("=== END DEBUGGING ===\n")
  })
  
  # Cleanup - remove temp CSV but keep all analysis outputs
  if (file.exists(temp_csv)) {
    file.remove(temp_csv)
  }
  setwd(original_wd)
  
  # Extract analysis settings from mSet object
  peak_format <- if(!is.null(mSet$paramSet$peakFormat)) mSet$paramSet$peakFormat else "rmp"
  enrich_method <- if(!is.null(mSet$paramSet$anal.type)) mSet$paramSet$anal.type else "mummichog"
  version <- if(!is.null(mSet$paramSet$version)) mSet$paramSet$version else "v2"
  
  # Extract actual p-value threshold used from mSet object or from our logic
  if (pval_peak_cutoff && exists("maxp")) {
    actual_pval_threshold <- maxp
  } else if (!pval_peak_cutoff) {
    actual_pval_threshold <- 1.0
  } else {
    # Fallback extraction from mSet object
    actual_pval_threshold <- if(!is.null(mSet$analSet$mummi.cutoff)) {
      mSet$analSet$mummi.cutoff
    } else if(!is.null(mSet$paramSet$mumPvalCutoff)) {
      mSet$paramSet$mumPvalCutoff
    } else {
      "unknown"
    }
  }
  
  # Also try to extract the actual threshold from mSet regardless of our parameter
  mset_threshold <- NULL
  if(!is.null(mSet$dataSet$cutoff)) {
    mset_threshold <- mSet$dataSet$cutoff
  } else if(!is.null(mSet$analSet$mummi.cutoff)) {
    mset_threshold <- mSet$analSet$mummi.cutoff
  } else if(!is.null(mSet$paramSet$mumPvalCutoff)) {
    mset_threshold <- mSet$paramSet$mumPvalCutoff
  }
  
  # If we found a more precise threshold in mSet, use that for display
  display_threshold <- if(!is.null(mset_threshold) && is.numeric(mset_threshold) && mset_threshold != 1.0) {
    mset_threshold
  } else {
    actual_pval_threshold
  }
  
  # P-value method description
  pval_method_desc <- if (pval_peak_cutoff) {
    "Top 10% of peaks (dynamic)"
  } else {
    "All peaks (p < 1.0)"
  }
  
  # Create the p-value setting description
  pval_setting_desc <- if (pval_peak_cutoff) {
    "- SetMummichogPvalFromPercent: 0.1 (top 10% of peaks)\n\n"
  } else {
    "- SetMummichogPval: 1.0 (all peaks)\n\n"
  }
  
  # Create the threshold description
  threshold_desc <- if (pval_peak_cutoff) "calculated" else "set"
  
  # Create parameter summary markdown
  md_content <- paste0(
    "# Mummichog Analysis Parameters\n\n",
    "**Analysis Date:** ", Sys.Date(), "\n\n",
    "**Database:** ", database, "\n\n",
    "**MetaboAnalystR 'Set' Function Outputs:**\n",
    "- SetPeakFormat: ", peak_format, "\n",
    "- SetPeakEnrichMethod: ", enrich_method, " (", version, ")\n",
    pval_setting_desc,
    "**Instrument Parameters (UpdateInstrumentParameters):**\n",
    "- instrumentOpt: ", instrumentOpt, "\n",
    "- msModeOpt: ", msModeOpt, "\n", 
    "- force_primary_ion: ", force_primary_ion, "\n",
    "- rt_frac: ", rt_frac, "\n\n",
    "**Analysis Parameters:**\n",
    "- Peak filtering method: ", pval_method_desc, "\n",
    "- Peak filtering p-value threshold (", threshold_desc, "): ", display_threshold, "\n",
    "- Pathway enrichment p-value threshold: 0.05 (fixed)\n",
    "- Minimum pathway size: 3\n",
    "- Permutations for background: 100\n\n",
    "**Input Data:**\n",
    "- Number of features: ", nrow(ttest_results), "\n",
    "- Output directory: ", output_dir, "\n"
  )
  
  # Write markdown file to output directory
  md_file <- file.path(output_dir, "analysis_parameters.md")
  cat("=== WRITING MARKDOWN FILE ===\n")
  cat("Attempting to write to:", md_file, "\n")
  cat("Current working directory:", getwd(), "\n")
  cat("Original working directory:", original_wd, "\n")
  
  writeLines(md_content, md_file)
  
  # Verify the file was created
  if (file.exists(md_file)) {
    cat("✓ Markdown file successfully created at:", md_file, "\n")
    cat("File size:", file.size(md_file), "bytes\n")
  } else {
    cat("✗ ERROR: Markdown file was NOT created!\n")
  }
  
  # Print p-value thresholds at the very end
  cat("=== P-VALUE SUMMARY ===\n")
  cat("Peak filtering p-value threshold:", display_threshold, "(", pval_method_desc, ")\n")
  if(!is.null(mset_threshold) && mset_threshold != display_threshold) {
    cat("MetaboAnalystR internal threshold:", mset_threshold, "\n")
  }
  cat("Pathway enrichment p-value threshold: 0.05 (fixed by PerformPSEA)\n")
  cat("Permutations for background estimation: 100\n")
  cat("Parameter summary saved to:", md_file, "\n")
  
  return(mSet)
}

