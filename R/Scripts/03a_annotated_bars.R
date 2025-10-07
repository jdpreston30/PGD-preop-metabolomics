#* 2: Metabolomic Features vs PGD Analysis 
#+ 2.1: T-tests for all metabolomic features against PGD status 
#- 2.1.1: Run T-test function for all targeted
feature_ttest_results <- run_targeted_ttests(
  feature_table = TFT,
  tft_key = TFT_key,
  grouping_var = "severe_PGD",
  fc_ref_group = "No Severe PGD"
)
#- 2.1.2: Remove low detects (things that were over 20% missingness and thus half min interp) Results
ttests_low_det_removed <- feature_ttest_results %>%
  filter(low_detect_likely == "N")
#- 2.1.3: Filter to significant values; inspect
inspect <- ttests_low_det_removed %>%
  filter(p_value < 0.05) %>%
  mutate(sig_ord = row_number()) %>%
  select(sig_ord, feature,
         identified_name, fold_change, mean_no_severe_pgd, mean_severe_pgd, p_value, p_value_fdr, isomer)
#+ 2.2: Inspect and Clean Features
#- 2.2.1: Exclude metabolites to remove per CJR research
inspect_pared <- inspect %>%
  filter(!identified_name %in% exclude_metabolites)
#- 2.2.2: Confirm no duplicates among remaining
duplicates <- inspect_pared %>%
  group_by(identified_name, isomer) %>%
  filter(n() > 1) %>%
  ungroup() %>%
  select(sig_ord, identified_name, feature, p_value)
#- 2.2.3: Confirm no isomers among remaining
isomers <- inspect_pared %>%
  filter(isomer == "Y") %>%
  select(sig_ord, identified_name, feature, isomer, p_value)
#+ 2.3: QC
#- 2.3.4: Remove bad annotations per CJR research
div_plot_data <- inspect %>%
  filter(!identified_name %in% exclude_metabolites) %>%
  # mark isomers
  mutate(
    identified_name = ifelse(isomer == "Y", paste0(identified_name, "*"), identified_name),
    # apply name map after isomer tagging
    identified_name = dplyr::recode(identified_name, !!!name_map)
  )
#- 2.3.2: Choose targeted to display
indv_plots <- div_plot_data %>%
  select(identified_name, p_value, p_value_fdr, feature) %>%
  filter(p_value < 0.01)
#- 2.3.3: Subset TFT to the chosen ones
TFT_indv <- TFT %>%
  select(severe_PGD, all_of(indv_plots$feature))
#+ 2.3: Visualize diverging bars
diverging_plot <- plot_diverging_bars(
  results_tibble = div_plot_data,
  max_features = 100,
  text_scale = 0.9
)
#+ 2.4: Visualize individual feature plots
significant_feature_plots <- plot_targeted(
  feature_table = TFT_indv,
  metadata_table = indv_plots,
  include_individual_points = TRUE,
  undo_log = TRUE,
  text_scale = 0.6
)
