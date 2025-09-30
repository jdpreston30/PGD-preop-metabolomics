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
#' @param p_threshold Numeric value for p-value threshold (default: 0.05)
#' @param enrichment_p_threshold Numeric value for enrichment p-value threshold (default: 0.1)
#'
#' @return A list containing pathway results, network data, and file paths
#'
#' @examples
#' results <- run_mummichog_analysis(
#'   ttest_results = my_ttest_tibble,
#'   analysis_name = "nosev",
#'   database = "hsa_mfn",
#'   base_output_dir = "Outputs/mummichog/outputs"
#' )
#'
#' @export
run_mummichog_analysis <- function(
  ttest_results,
  analysis_name,
  database = "hsa_mfn",
  output_base_dir = "../../Outputs/mummichog/outputs",
  ppm_tolerance = 5.0,
  instrument_type = "mixed",
  adducts_included = "yes",
  rt_tolerance = 0.02,
  p_threshold = 0.1,
  min_pathway_size = 3,
  permutations = 100,
  create_network = TRUE,
  plot_width = 150,
  dpi = 150
) {
  
  # Load required libraries
  library(MetaboAnalystR)
  library(dplyr)
  
  # Source network function
  if (create_network && !exists("prepare_custom_enrichnet")) {
    source("../Utilities/Analysis/build_network.R")
  }
  
  # Validate database
  if (!database %in% c("hsa_mfn", "hsa_kegg")) {
    stop("Database must be 'hsa_mfn' or 'hsa_kegg'")
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
    
    # Build analysis pipeline
    mSet <- InitDataObjects("mass_all", "mummichog", FALSE, dpi) %>%
      SetPeakFormat("rmp") %>%
      UpdateInstrumentParameters(ppm_tolerance, instrument_type, adducts_included, rt_tolerance) %>%
      Read.PeakListData(temp_csv) %>%
      SanityCheckMummichogData() %>%
      SetPeakEnrichMethod("mum", "v2") %>%
      SetMummichogPval(p_threshold) %>%
      PerformPSEA(database, "current", min_pathway_size, permutations) %>%
      PlotPeaks2Paths(paste0("metaboanalyst_", tolower(db_name), "_"), "png", dpi, width = NA)
    
    cat("✓", db_name, "analysis completed successfully\n")
    
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