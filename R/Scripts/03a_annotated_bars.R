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
  mutate(log2FC = log2(fold_change)) %>%
  select(sig_ord, identified_name, log2FC, isomer, multi_mode_detection, feature, p_value, p_value_fdr)
write.csv(inspect, "Outputs/data_not_shown/annot_inspection.csv", row.names = FALSE)
#+ 2.2: Inspect and Clean Features
#- 2.2.0: Read in updated annotation inspection file; clean
annot_inspection <- readxl::read_excel(config$paths$annot_inspection) %>%
rename(name = identified_name) %>%
filter(include == "Y") %>%
select(sig_ord, name, short_name, p_value, p_value_fdr, log2FC)
#- 2.2.1: Pull Names
include_metabolites <- annot_inspection  %>%
  pull(sig_ord)
#- 2.2.2: Exclude metabolites to remove per CJR research
inspect_pared <- inspect %>%
  filter(sig_ord %in% include_metabolites) %>%
  left_join(annot_inspection %>% select(sig_ord, short_name), by = "sig_ord") %>%
  select(feature, long_name = identified_name, identified_name = short_name, everything())
#- 2.2.3: Confirm no duplicates among remaining
duplicates <- inspect_pared %>%
  group_by(identified_name, isomer) %>%
  filter(n() > 1) %>%
  ungroup() %>%
  select(sig_ord, identified_name, feature)
#- 2.2.4: Confirm no isomers among remaining
isomers <- inspect_pared %>%
  filter(isomer == "Y") %>%
  select(sig_ord, identified_name, feature, isomer, p_value) #! Both manually annotated with
#-2.2.6: Pull indv plots
indv_plots <- inspect_pared %>%
  filter(sig_ord %in% annot_inspection$sig_ord) %>%
  select(sig_ord, identified_name, p_value, p_value_fdr, feature)
#- 2.2.6: Subset TFT to the chosen ones
TFT_indv <- TFT %>%
  select(severe_PGD, all_of(indv_plots$feature))
#+ 2.3: Visualize diverging bars
#- 2.3.1: Filter Data to 2 FC
inspect_pared_2 <- inspect_pared %>%
  filter(abs(log2FC) >= log2(2)) %>%
  arrange(log2FC)
#- 2.3.2: Create diverging bar plot
diverging_plot <- plot_diverging_bars(
  results_tibble = inspect_pared_2,
  max_features = 100,
  text_scale = 0.9
)
#+ 2.4: Visualize individual feature plots
#- 2.4.1: Create individual plots for all significant features
significant_feature_plots <- plot_targeted(
  feature_table = TFT_indv,
  metadata_table = indv_plots,
  include_individual_points = TRUE,
  undo_log = TRUE,
  text_scale = 0.6,
  sig_ord_title = FALSE
)
#- 2.4.2: Vectorize those that failed visual inspect
bad_plots <- c(16, 17, 22, 29, 39, 41, 65, 15, 146, 150, 153, 155, 174, 184, 186, 187)
#- 2.4.3: Remove bad plots from significant_feature_plots
significant_feature_plots <- significant_feature_plots[!names(significant_feature_plots) %in% as.character(bad_plots)]
#- 2.4.4: Inspect names of remaining
indv_plots_names <- indv_plots %>%
  filter(!sig_ord %in% bad_plots) %>%
  select(sig_ord, identified_name)
#- 2.4.5: Choose targeted to display
sig_groups <- list(
  redox_ppp        = c(6, 3, 9, 95),
  lipid_remodel    = c(5, 68, 121, 134),
  amino_nitrogen   = c(2, 42, 157, 61),
  heme_antioxidant = c(32, 45)
)
#- 2.4.6:  Create grouped plot lists
redox_ppp_plots <- significant_feature_plots[as.character(sig_groups$redox_ppp)]
lipid_remodel_plots <- significant_feature_plots[as.character(sig_groups$lipid_remodel)]
amino_nitrogen_plots <- significant_feature_plots[as.character(sig_groups$amino_nitrogen)]
heme_antioxidant_plots <- significant_feature_plots[as.character(sig_groups$heme_antioxidant)]
