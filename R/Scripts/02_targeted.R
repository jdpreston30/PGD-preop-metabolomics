
#* 2: Metabolomic Features vs PGD Analysis ----
#+ 2.1: T-tests for all metabolomic features against PGD status ----
cat("\n=== METABOLOMIC FEATURES vs PGD ANALYSIS ===\n")

# Get metabolomic feature columns (exclude Patient and PGD)
feature_cols <- names(TFT)[!names(TFT) %in% c("Patient", "PGD")]
cat("Testing", length(feature_cols), "metabolomic features against PGD status\n")

# Create results dataframe
metabolite_results <- data.frame(
    Feature = character(),
    P_Value = numeric(),
    Mean_No_PGD = numeric(),
    Mean_PGD = numeric(),
    Log2_Fold_Change = numeric(),
    Fold_Change = numeric(),
    stringsAsFactors = FALSE
  )
  
  # Loop through all metabolomic features
  for (feature in feature_cols) {
    tryCatch({
      feature_data <- TFT[[feature]]
      
      # Skip if all NA
      if (all(is.na(feature_data))) {
        next
      }
      
      # Run t-test
      test_result <- t.test(feature_data ~ TFT$PGD)
      
      # Calculate means (log2 values)
      mean_no_pgd <- mean(feature_data[TFT$PGD == "N"], na.rm = TRUE)
      mean_pgd <- mean(feature_data[TFT$PGD == "Y"], na.rm = TRUE)
      # For log2 data: fold_change = 2^(mean_pgd - mean_no_pgd)
      log2_fold_change <- mean_pgd - mean_no_pgd
      fold_change <- 2^log2_fold_change
      
      # Add to results
      metabolite_results <- rbind(metabolite_results, data.frame(
        Feature = feature,
        P_Value = test_result$p.value,
        Mean_No_PGD = round(mean_no_pgd, 4),
        Mean_PGD = round(mean_pgd, 4),
        Log2_Fold_Change = round(log2_fold_change, 4),
        Fold_Change = round(fold_change, 4)
      ))
      
    }, error = function(e) {
      cat("Skipped", feature, "due to error\n")
    })
  }
  
  # Sort by p-value
  metabolite_results <- metabolite_results[order(metabolite_results$P_Value), ]
  
  # Join with feature identification key
  metabolite_results_annotated <- metabolite_results %>%
    left_join(TFT_key %>% select(Feature, Name, `Identified Name`), by = "Feature") %>%
    relocate(Feature, Name, `Identified Name`, .before = P_Value) %>%
    as_tibble() %>%
    arrange(`Identified Name`) %>%
    arrange(P_Value)
write.csv(metabolite_results_annotated,"metabolite_PGD_ttests.csv")
  
  # Display full results
  cat("\nFull metabolomic feature results vs PGD:\n")
print(metabolite_results_annotated, n = Inf)
