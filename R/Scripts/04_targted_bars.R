#* 4: Targeted and Quantified Features Analysis
#+ 4.1: T-tests for all metabolomic features against PGD status 
#- 4.1.1: Run T-test function for all targeted
TFT_conf_ttests <- run_targeted_ttests(
  feature_table = TFT_confirmed,
  tft_key = TFT_confirmed_key,
  grouping_var = "severe_PGD",
  fc_ref_group = "No Severe PGD"
)
#- 4.1.3: Filter to significant values; inspect
inspect_TFT_conf <- TFT_conf_ttests %>%
  mutate(
    sig_ord = row_number(),
    in_MSMICA = ifelse(feature %in% feature_ttest_results$feature, "Y", "N")
  ) %>%
  arrange(p_value) %>%
  select(in_MSMICA, sig_ord, p_value, p_value_fdr,
         identified_name, fold_change, mean_no_severe_pgd, mean_severe_pgd, feature, isomer)
#+ 4.2: Subset
#- 4.3.1: Rename map to cleanup names
rename_map <- c(
  "HISTAMINE" = "Histamine**",
  "PIPECOLATE" = "Pipecolate**",
  "4-METHYL-2-OXO-PENTANOIC ACID" = "α-Ketoisocaproate**",
  "ESTRADIOL-17ALPHA" = "17α-Estradiol**"
)
#- 4.2.2: Pare; rename
conf_plots <- inspect_TFT_conf %>%
  select(identified_name, p_value, p_value_fdr, feature) %>%
  mutate(identified_name = dplyr::recode(identified_name, !!!rename_map))
#- 4.3.3: Subset TFT to the chosen ones; rename
conf_TFT_indv <- TFT_confirmed %>%
  select(severe_PGD, all_of(conf_plots$feature))
#+ 4.3: Visualize diverging bars
diverging_plot_conf <- plot_diverging_bars(
  results_tibble = inspect_TFT_conf,
  max_features = 100,
  text_scale = 0.9
)
#+ 4.4: Visualize individual feature plots
conf_plots <- plot_targeted(
  feature_table = TFT_confirmed,
  metadata_table = conf_plots,
  include_individual_points = TRUE,
  undo_log = TRUE,
  text_scale = 0.6
)

