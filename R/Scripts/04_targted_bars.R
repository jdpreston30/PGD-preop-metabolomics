#* 4: Targeted and Quantified Features Analysis
#+ 4.1: T-tests for all metabolomic features against PGD status 
#- 4.1.1: Run T-test function for all targeted
TFT_conf_ttests <- run_targeted_ttests(
  feature_table = TFT_confirmed,
  tft_key = TFT_confirmed_key,
  grouping_var = "severe_PGD",
  fc_ref_group = "No Severe PGD"
)
#- 3.1.2: Remove low detects (things that were over 20% missingness and thus half min interp) Results
TFT_conf_ttests_low_det_removed <- TFT_conf_ttests %>%
  filter(low_detect_likely == "N")
#- 4.1.3: Filter to significant values; inspect
inspect_TFT_conf <- TFT_conf_ttests_low_det_removed %>%
  mutate(
    sig_ord = row_number(),
    in_annot = ifelse(feature %in% feature_ttest_results$feature, "Y", "N"),
    annot_sig = ifelse(feature %in% annot_inspection$feature, "Y", "N")
  ) %>%
  left_join(annot_inspection %>% select(feature, annot_name = short_name, sig_ord_annot = sig_ord), by = "feature") %>%
  arrange(p_value)
write.csv(inspect_TFT_conf, "Outputs/data_not_shown/targeted_conf_inspection.csv", row.names = FALSE)
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

