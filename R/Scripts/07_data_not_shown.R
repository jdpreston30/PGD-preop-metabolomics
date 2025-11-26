#* 7: Data Not Shown
#' Calculates supplementary statistics and text for manuscript methods/results.
#' Computes sample processing time statistics (elapsed time from collection to processing).
#' Generates sample composition percentages (arterial vs venous blood samples).
#' Calculates PGD grade distributions and creates descriptive sentences for manuscript text.
#+ 7.0: Sample Processing Time
#- 7.0.1: Compute Elapsed Minutes
processing_time <- sample_type %>%
  mutate(
    sample_dt = as.POSIXct(paste(as.Date(sample_date), format(sample_time, "%H:%M:%S")), tz = "UTC"),
    processing_dt = as.POSIXct(paste(as.Date(processing_date), format(processing_time, "%H:%M:%S")), tz = "UTC"),
    processing_dt = if_else(processing_dt < sample_dt,
      processing_dt + days(1),
      processing_dt
    ),
    elapsed_min = as.numeric(difftime(processing_dt, sample_dt, units = "mins")),
    elapsed_hr = elapsed_min / 60
  ) %>%
  select(Patient, Sample, sample_dt, processing_dt, elapsed_min, elapsed_hr) %>%
  summarise(
    min_hr = min(elapsed_hr, na.rm = TRUE),
    max_hr = max(elapsed_hr, na.rm = TRUE),
    mean_hr = mean(elapsed_hr, na.rm = TRUE)
  )
#+ 7.1: Percent of samples arterial versus venous
#- 7.1.1: Generate sample composition summary 
sample_summary <- sample_type %>%
  summarise(
    total_samples = n(),
    arterial_count = sum(sample_source == "A", na.rm = TRUE),
    venous_count = sum(sample_source == "V", na.rm = TRUE),
    arterial_percent = round_half_up((arterial_count / total_samples) * 100),
    venous_percent = round_half_up((venous_count / total_samples) * 100)
  )
#- 7.1.2: Create the summary sentence 
sample_composition_text <- paste0(
  "Of the ", sample_summary$total_samples, " samples run, ",
  sample_summary$arterial_count, " (", round_half_up(sample_summary$arterial_percent), "%) were arterial and ",
  sample_summary$venous_count, " (", round_half_up(sample_summary$venous_percent), "%) were venous."
)
#+ 7.2: Rates and n's of PGD grade 
#- 7.2.1: Compute the counts and percentages of each PGD grade 
postop_PGD_grade_ISHLT_counts <- clinical_metadata %>%
  group_by(postop_PGD_grade_ISHLT) %>%
  summarise(n = n()) %>%
  mutate(percentage = n / sum(n) * 100)
#- 7.2.2: Create and display results sentence 
pgd_grades_sentence <- paste("Of the", sum(postop_PGD_grade_ISHLT_counts$n), "patients,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "N"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "N"]), "%)"), "had no PGD,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Mild"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Mild"]), "%)"), "had mild PGD,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Moderate"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Moderate"]), "%)"), "had moderate PGD, and",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Severe"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Severe"]), "%)"), "had severe PGD.")
#- 7.2.3: Create processing time sentence
processing_time_sentence <- paste0(
  "Sample processing times ranged from ", round(processing_time$min_hr, 2), " to ", round(processing_time$max_hr, 2), 
  " hours (mean = ", round(processing_time$mean_hr, 2), " hours)."
)
#+ 7.3: Number of total features
#- 7.3.1: Count columns by chromatography method (UFT)
hilic_count <- UFT %>% 
  select(starts_with("HILIC")) %>% 
  ncol()
c18_count <- UFT %>% 
  select(starts_with("C18")) %>% 
  ncol()
total_chrom_count <- hilic_count + c18_count
#- 7.3.2: Count columns by chromatography method (UFT filtered)
hilic_count_filtered <- UFT_filtered %>% 
  select(starts_with("HILIC")) %>% 
  ncol()
c18_count_filtered <- UFT_filtered %>% 
  select(starts_with("C18")) %>% 
  ncol()
total_chrom_count_filtered <- hilic_count_filtered + c18_count_filtered
#- 7.3.3: Create narrative sentences for feature counts
feature_counts_sentence <- paste0(
  "A total of ", total_chrom_count, " metabolomic features were detected across both chromatography methods (",
  hilic_count, " HILIC and ", c18_count, " C18 features). After filtering based on QC measures, ",
  total_chrom_count_filtered, " features remained (",
  hilic_count_filtered, " HILIC and ", c18_count_filtered, " C18 features)."
)
#+ 7.4: Volcano Plot Statistics for Manuscript
#- 7.4.1: Extract counts from volcano analysis results
# Total significantly different features (p < 0.05)
total_sig <- volcano_allsev_data$volcano_data %>%
  filter(p_value < volcano_allsev_data$p_threshold) %>%
  nrow()
# Features that are significantly upregulated AND meet fold change threshold
up_sig_fc <- volcano_allsev_data$volcano_data %>%
  filter(p_value < volcano_allsev_data$p_threshold & 
         log2_fc >= volcano_allsev_data$fc_threshold) %>%
  nrow()
# Features that are significantly downregulated AND meet fold change threshold  
down_sig_fc <- volcano_allsev_data$volcano_data %>%
  filter(p_value < volcano_allsev_data$p_threshold & 
         log2_fc <= -volcano_allsev_data$fc_threshold) %>%
  nrow()
#- 7.4.2: Display results and create narrative sentence
cat("\nVolcano Plot Statistics:\n")
cat("=========================\n")
cat("FC threshold (log2):", volcano_allsev_data$fc_threshold, "(=", round(2^volcano_allsev_data$fc_threshold, 1), "-fold)\n")
cat("P-value threshold:", volcano_allsev_data$p_threshold, "\n")
cat("Total significantly different features:", total_sig, "\n")
cat("Significantly higher in PGD group (≥1.5-fold):", up_sig_fc, "\n")
cat("Significantly lower in PGD group (≥1.5-fold):", down_sig_fc, "\n")
#- 7.4.3: Create manuscript sentence
volcano_results_sentence <- paste0(
  "Further analysis identified ", total_sig, " significantly different untargeted metabolite features between ",
  "groups, among which ", up_sig_fc, " metabolites were at least 1.5-fold higher in the PGD group, ",
  "while ", down_sig_fc, " metabolites were at least 1.5-fold lower."
)
#+ 7.5: Targeted Analysis Statistics  
#- 7.5.1: Calculate targeted detection and significance statistics
total_detected <- nrow(TFT_combined_results)
significant_features <- sum(TFT_combined_results$p_value < 0.05, na.rm = TRUE)  
annotated_significant <- nrow(TFT_sig_metadata)
#- 7.5.2: Create targeted results summary sentence
targeted_results_sentence <- paste0(
  "Of ", total_detected, " detected features, ", significant_features, " were significant (p < 0.05), ",
  "of which ", annotated_significant, " were annotated."
)
#+ 7.6: Sample Size and Power Calculation
#- 7.6.1: Compute n's per group
n1 <- sum(UFT_filtered$severe_PGD == "Severe PGD")
n2 <- sum(UFT_filtered$severe_PGD == "No Severe PGD")
#- 7.6.2: Compute detectable effect size for two-sample t-test (unequal n)
power_result <- pwr.t2n.test(n1 = n1, n2 = n2, sig.level = 0.05, power = 0.8)
#- 7.6.3: Compute per-feature pooled SD and minimum detectable fold-change
feature_cols <- setdiff(
  colnames(UFT_filtered),
  c("Patient", "severe_PGD", "PGD_grade_tier", "any_PGD")
)
per_feature_fc_sensitivity <- UFT_filtered %>%
  select(severe_PGD, all_of(feature_cols)) %>%
  pivot_longer(-severe_PGD, names_to = "feature", values_to = "value") %>%
  group_by(feature) %>%
  summarize(
    n1 = sum(severe_PGD == "Severe PGD", na.rm = TRUE),
    n2 = sum(severe_PGD == "No Severe PGD", na.rm = TRUE),
    var1 = var(value[severe_PGD == "Severe PGD"], na.rm = TRUE),
    var2 = var(value[severe_PGD == "No Severe PGD"], na.rm = TRUE),
    s_pooled = sqrt(((n1 - 1) * var1 + (n2 - 1) * var2) / (n1 + n2 - 2)),
    delta_log2_min = power_result$d * s_pooled, # minimum detectable mean difference (log2 units)
    fc_min = 2^(delta_log2_min), # minimum detectable fold-change
    .groups = "drop"
  )
#- 7.6.4: Summarize fold-change sensitivity
fc_summary <- per_feature_fc_sensitivity %>%
  summarize(
    median_fc   = median(fc_min, na.rm = TRUE),
    p25_fc      = quantile(fc_min, 0.25, na.rm = TRUE),
    p75_fc      = quantile(fc_min, 0.75, na.rm = TRUE)
  )
#- 7.6.5: Generate narrative sensitivity summary
sensitivity_sentence <- paste0(
  "With ", n1 + n2, " patients (", n1, " with severe PGD and ", n2,
  " without), we had ~80% power (α=0.05) to detect a minimum standardized mean difference of Cohen's d ≈ ",
  round(power_result$d, 2), ". Based on observed within-group variance, the median minimum detectable fold-change was ",
  round(fc_summary$median_fc, 2), "× (IQR ", round(fc_summary$p25_fc, 2), "–", round(fc_summary$p75_fc, 2), "×) across all features."
)
#+ 7.7: Demographic Ranges
range(T1_data$demographics_age_tpx)
#+ 7.8: Manuscript sentences summary 
cat(
  "\n",
  strrep("=", 60), "\n",
  "MANUSCRIPT SENTENCES FOR COPY-PASTE\n",
  strrep("=", 60), "\n",
  "\n",
  "\033[1;31mSentence for methods on sample types:\033[0m\n",  # Bold red header
  "\033[3;31m", sample_composition_text, "\033[0m\n",  # Italicized red sentence
  "\n",
  "\033[1;32mSentence for results on PGD grades:\033[0m\n",  # Bold green header
  "\033[3;32m", pgd_grades_sentence, "\033[0m\n",  # Italicized green sentence
  "\n",
  "\033[1;34mSentence for methods on sample processing times:\033[0m\n",  # Bold blue header
  "\033[3;34m", processing_time_sentence, "\033[0m\n",  # Italicized blue sentence
  "\n",
  "\033[1;35mSentence for methods on feature counts:\033[0m\n",  # Bold magenta header
  "\033[3;35m", feature_counts_sentence, "\033[0m\n",  # Italicized magenta sentence
  "\n",
  "\033[1;36mSentence for results on volcano plot analysis:\033[0m\n",  # Bold cyan header
  "\033[3;36m", volcano_results_sentence, "\033[0m\n",  # Italicized cyan sentence
  "\n",
  "\033[1;37mSentence for results on targeted analysis:\033[0m\n",  # Bold white header
  "\033[3;37m", targeted_results_sentence, "\033[0m\n",  # Italicized white sentence
  "\n",
  "\033[1;33mSentence for methods on sensitivity analysis:\033[0m\n",  # Bold yellow header
  "\033[3;33m", sensitivity_sentence, "\033[0m\n",  # Italicized yellow sentence
  "\n",
  strrep("=", 60), "\n",
  "\n"
)
