#' Comprehensive Dataset Comparison Pipeline
#' 
#' This script performs systematic comparisons between three metabolomic datasets:
#' 1. TFT_annot vs TFT_confirmed - Annotated vs confirmed features
#' 2. TFT_annot vs UFT - Annotated vs full untargeted  
#' 3. TFT_confirmed vs UFT - Confirmed vs full untargeted
#' 
#' For each comparison, the script:
#' - Finds features with perfectly matching column names
#' - Checks if matching features have identical values (100% match)
#' - Reports summary statistics and conclusions
#'
#' Expected relationships:
#' - TFT_confirmed should be subset of both TFT_annot and UFT
#' - TFT_annot should be subset of UFT

# Load all necessary data first
source("R/Utilities/Helpers/load_dynamic_config.R")
config <- load_dynamic_config(computer = "auto", config_path = "All_run/config_dynamic.yaml")
source("R/Scripts/00a_environment_setup.R")
source("R/Scripts/00b_setup.R")
source("R/Scripts/00c_clinical_metadata.R")
source("R/Scripts/00d_FTs.R")

# Check if all required datasets exist
required_datasets <- c("TFT_annot", "TFT_confirmed", "UFT")
missing_datasets <- required_datasets[!sapply(required_datasets, exists)]

if (length(missing_datasets) > 0) {
  stop("Missing required datasets: ", paste(missing_datasets, collapse = ", "))
}

library(dplyr)

# Function to compare two datasets
compare_datasets <- function(dataset1, dataset2, name1, name2) {
  cat("\n", rep("=", 80), "\n", sep = "")
  cat("COMPARISON: ", name1, " vs ", name2, "\n")
  cat(rep("=", 80), "\n", sep = "")
  
  # Get column names from both datasets
  cols1 <- colnames(dataset1)
  cols2 <- colnames(dataset2)
  
  cat("\nDataset Dimensions:\n")
  cat(name1, ": ", nrow(dataset1), " rows x ", ncol(dataset1), " columns\n")
  cat(name2, ": ", nrow(dataset2), " rows x ", ncol(dataset2), " columns\n")
  
  # Identify feature columns (start with C18 or HILIC) vs metadata columns
  feature_cols1 <- cols1[grepl("^(C18|HILIC)", cols1)]
  metadata_cols1 <- cols1[!grepl("^(C18|HILIC)", cols1)]
  
  feature_cols2 <- cols2[grepl("^(C18|HILIC)", cols2)]
  metadata_cols2 <- cols2[!grepl("^(C18|HILIC)", cols2)]
  
  cat("\nFeature Column Counts:\n")
  cat(name1, " feature columns: ", length(feature_cols1), "\n")
  cat(name2, " feature columns: ", length(feature_cols2), "\n")
  cat(name1, " metadata columns: ", length(metadata_cols1), "\n")
  cat(name2, " metadata columns: ", length(metadata_cols2), "\n")
  
  # Find perfectly matching feature column names
  matching_features <- intersect(feature_cols1, feature_cols2)
  only_in_1 <- setdiff(feature_cols1, feature_cols2)
  only_in_2 <- setdiff(feature_cols2, feature_cols1)
  
  cat("\nFeature Column Name Analysis:\n")
  cat("Perfect matches: ", length(matching_features), "\n")
  cat("Only in ", name1, ": ", length(only_in_1), "\n")
  cat("Only in ", name2, ": ", length(only_in_2), "\n")
  
  # Value comparison for matching features
  identical_values <- 0
  different_values <- 0
  
  if (length(matching_features) > 0) {
    cat("\n--- Checking Values in Matching Features ---\n")
    
    # Sort both datasets by Patient to ensure proper comparison
    dataset1_sorted <- dataset1 %>% arrange(Patient)
    dataset2_sorted <- dataset2 %>% arrange(Patient)
    
    # Check if Patient columns are identical
    patients_match <- identical(dataset1_sorted$Patient, dataset2_sorted$Patient)
    cat("Patient columns match: ", patients_match, "\n")
    
    if (!patients_match) {
      cat("WARNING: Patient columns differ! Value comparison may be unreliable.\n")
      cat(name1, " patients (first 10): ", paste(head(dataset1_sorted$Patient, 10), collapse = ", "), "\n")
      cat(name2, " patients (first 10): ", paste(head(dataset2_sorted$Patient, 10), collapse = ", "), "\n")
    } else {
      cat("Comparing values for ", length(matching_features), " matching features...\n")
      
      # Compare each matching feature
      for (feature in matching_features) {
        values1 <- dataset1_sorted[[feature]]
        values2 <- dataset2_sorted[[feature]]
        
        if (identical(values1, values2)) {
          identical_values <- identical_values + 1
        } else {
          different_values <- different_values + 1
        }
      }
      
      cat("\nValue Comparison Results:\n")
      cat("Features with IDENTICAL values: ", identical_values, "\n")
      cat("Features with DIFFERENT values: ", different_values, "\n")
      
      # Calculate percentage
      if (length(matching_features) > 0) {
        percent_identical <- round(100 * identical_values / length(matching_features), 2)
        cat("Percentage with identical values: ", percent_identical, "%\n")
      }
    }
  } else {
    cat("No matching feature columns found - cannot compare values.\n")
  }
  
  # Summary conclusion
  cat("\n--- CONCLUSION ---\n")
  if (length(matching_features) == 0) {
    cat("✗ NO overlap: Completely different feature sets\n")
  } else if (identical_values == length(matching_features)) {
    cat("✓ PERFECT SUBSET: All ", length(matching_features), " matching features have identical values\n")
  } else if (identical_values > 0) {
    cat("◐ PARTIAL MATCH: ", identical_values, "/", length(matching_features), " features have identical values\n")
  } else {
    cat("✗ NO IDENTICAL VALUES: All ", length(matching_features), " matching features have different values\n")
  }
  
  # Return summary statistics
  return(list(
    comparison = paste(name1, "vs", name2),
    total_features_1 = length(feature_cols1),
    total_features_2 = length(feature_cols2),
    matching_features = length(matching_features),
    only_in_1 = length(only_in_1),
    only_in_2 = length(only_in_2),
    identical_values = identical_values,
    different_values = different_values,
    patients_match = if(length(matching_features) > 0) patients_match else NA
  ))
}

# Perform all three comparisons
cat("\n", rep("#", 100), "\n")
cat("COMPREHENSIVE METABOLOMIC DATASET COMPARISON PIPELINE")
cat("\n", rep("#", 100), "\n")

# Comparison 1: TFT_annot vs TFT_confirmed
result1 <- compare_datasets(TFT_annot, TFT_confirmed, "TFT_annot", "TFT_confirmed")

# Comparison 2: TFT_annot vs UFT
result2 <- compare_datasets(TFT_annot, UFT, "TFT_annot", "UFT")

# Comparison 3: TFT_confirmed vs UFT  
result3 <- compare_datasets(TFT_confirmed, UFT, "TFT_confirmed", "UFT")

# Final summary table
cat("\n", rep("=", 80), "\n")
cat("FINAL SUMMARY TABLE")
cat("\n", rep("=", 80), "\n")

summary_table <- data.frame(
  Comparison = c(result1$comparison, result2$comparison, result3$comparison),
  Dataset1_Features = c(result1$total_features_1, result2$total_features_1, result3$total_features_1),
  Dataset2_Features = c(result1$total_features_2, result2$total_features_2, result3$total_features_2),
  Matching_Names = c(result1$matching_features, result2$matching_features, result3$matching_features),
  Identical_Values = c(result1$identical_values, result2$identical_values, result3$identical_values),
  Different_Values = c(result1$different_values, result2$different_values, result3$different_values),
  Percent_Identical = c(
    if(result1$matching_features > 0) round(100 * result1$identical_values / result1$matching_features, 1) else 0,
    if(result2$matching_features > 0) round(100 * result2$identical_values / result2$matching_features, 1) else 0,
    if(result3$matching_features > 0) round(100 * result3$identical_values / result3$matching_features, 1) else 0
  )
)

print(summary_table)

cat("\n--- PIPELINE INTERPRETATION ---\n")
cat("Perfect Subset (100% identical): Dataset 1 is a perfect subset of Dataset 2\n")
cat("Partial Match (0-99% identical): Some features match, others don't - different processing\n") 
cat("No Match (0% identical): Same feature names but completely different processing/transformation\n")
cat("No Overlap: Completely different feature sets\n")

cat("\n=== PIPELINE COMPLETE ===\n")