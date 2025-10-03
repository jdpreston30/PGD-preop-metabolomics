
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
#- 2.1.4: QC- Remove bad annotations per CJR research
#! All performed and defined externally (targeted_exclude.R, targeted_names.R)
div_plot_data <- inspect %>%
  filter(!identified_name %in% exclude_metabolites) %>%
  # mark isomers
  mutate(
    identified_name = ifelse(isomer == "Y", paste0(identified_name, "*"), identified_name),
    # apply name map after isomer tagging
    identified_name = dplyr::recode(identified_name, !!!name_map)
  )
#- 2.1.5: Choose targeted to display
indv_plots <- div_plot_data %>%
  select(identified_name, p_value, p_value_fdr, feature) %>%
  filter(p_value < 0.01)
TFT_indv <- TFT %>%
  select(severe_PGD, all_of(indv_plots$feature))
#+ 2.2: Visualize diverging bars
diverging_plot <- plot_diverging_bars(
  results_tibble = div_plot_data,
  max_features = 100
) 
#+ 2.3: Visualize individual feature plots
source("R/Utilities/Visualization/plot_targeted.R")
significant_feature_plots <- plot_targeted(
  ttest_results = ttests_low_det_removed,
  feature_data = TFT,
  plot_mode = "fdr_p",
  include_individual_points = TRUE,
  show_significance_bars = FALSE,
  print_p = FALSE,
  print_p_fdr = TRUE,
  undo_log = TRUE
)
#+ 2.3
for (i in seq_along(significant_feature_plots)) {
  feature_name <- names(significant_feature_plots)[i]
  ggsave(
    filename = paste0("Figures/Raw/targ_", feature_name, ".png"),
    plot = significant_feature_plots[[i]],
    width = 3,
    height = 3,
    dpi = 600,
    bg = "white"
  )
}