#* 3: Annotated Features Analsyis
#+ 3.1: T-tests for all metabolomic features against PGD status 
#- 3.1.1: Run T-test function for all targeted
feature_ttest_results <- run_targeted_ttests(
  feature_table = TFT_annot,
  tft_key = TFT_key,
  grouping_var = "severe_PGD",
  fc_ref_group = "No Severe PGD"
)
#- 3.1.2: Remove low detects (things that were over 20% missingness and thus half min interp) Results
ttests_low_det_removed <- feature_ttest_results %>%
  filter(low_detect_likely == "N")
#- 3.1.3: Filter to significant values; inspect
inspect <- ttests_low_det_removed %>%
  filter(p_value < 0.05) %>%
  mutate(sig_ord = row_number()) %>%
  mutate(log2FC = log2(fold_change)) %>%
  select(sig_ord, identified_name, log2FC, isomer, multi_mode_detection, feature, p_value, p_value_fdr)
write.csv(inspect, "Outputs/data_not_shown/annot_inspection.csv", row.names = FALSE)
#+ 3.2: Inspect and Clean Features
#- 3.2.0: Read in updated annotation inspection file; clean
annot_inspection <- readxl::read_excel(config$paths$annot_inspection) %>%
rename(name = identified_name) %>%
filter(include == "Y") %>%
select(sig_ord, name, short_name, p_value, p_value_fdr, log2FC, isomer_names, abbreviated, feature)
#- 3.2.1: Pull Names
include_metabolites <- annot_inspection  %>%
  pull(sig_ord)
#- 3.2.2: Exclude metabolites to remove per CJR research
inspect_pared <- inspect %>%
  filter(sig_ord %in% include_metabolites) %>%
  left_join(annot_inspection %>% select(sig_ord, short_name), by = "sig_ord") %>%
  select(feature, long_name = identified_name, identified_name = short_name, everything())
#- 3.2.3: Confirm no duplicates among remaining
duplicates <- inspect_pared %>%
  group_by(identified_name, isomer) %>%
  filter(n() > 1) %>%
  ungroup() %>%
  select(sig_ord, identified_name, feature)
#- 3.2.4: Confirm no isomers among remaining
isomers <- inspect_pared %>%
  filter(isomer == "Y") %>%
  select(sig_ord, identified_name, feature, isomer, p_value) #! Both manually annotated with
#- 3.2.6: Pull indv plots
indv_plots <- inspect_pared %>%
  filter(sig_ord %in% annot_inspection$sig_ord) %>%
  select(sig_ord, identified_name, p_value, p_value_fdr, feature)
#- 3.2.6: Subset TFT_annot to the chosen ones
TFT_indv <- TFT_annot %>%
  select(severe_PGD, all_of(indv_plots$feature))
#+ 3.3: Visualize diverging bars
#- 3.3.1: Filter Data to 2 FC
inspect_pared_2 <- inspect_pared %>%
  filter(abs(log2FC) >= log2(2)) %>%
  arrange(log2FC)
#- 3.3.2: Create diverging bar plot
diverging_plot <- plot_diverging_bars(
  results_tibble = inspect_pared_2,
  max_features = 100,
  text_scale = 0.9
)
#+ 3.4: Visualize individual feature plots
#- 3.4.1: Create individual plots for all significant features
significant_feature_plots_chosen <- plot_targeted(
  feature_table = TFT_indv,
  metadata_table = indv_plots,
  include_individual_points = TRUE,
  undo_log = TRUE,
  text_scale = 0.6,
  sig_ord_title = FALSE
)
#- 3.4.2: Vectorize those that failed visual inspect
bad_plots <- c(16, 17, 22, 29, 39, 41, 65, 15, 146, 150, 153, 155, 174, 184, 186, 187)
#- 3.4.3: Remove bad plots from significant_feature_plots_chosen
significant_feature_plots_chosen <- significant_feature_plots_chosen[!names(significant_feature_plots_chosen) %in% as.character(bad_plots)]
#- 3.4.4: Inspect names of remaining
indv_plots_names <- indv_plots %>%
  filter(!sig_ord %in% bad_plots) %>%
  select(sig_ord, identified_name)
#- 3.4.5: Choose targeted to display
#!!!!!!!!!!!!!!!!!!
sig_groups <- list(
  redox_ppp        = c(6, 3, 9, 95),
  lipid_remodel    = c(5, 68, 121, 134),
  amino_nitrogen   = c(2, 42, 157, 61),
  heme_antioxidant = c(32, 45)
)
#- 3.4.6:  Create grouped plot lists
{
redox_ppp_plots <- significant_feature_plots_chosen[as.character(sig_groups$redox_ppp)]
lipid_remodel_plots <- significant_feature_plots_chosen[as.character(sig_groups$lipid_remodel)]
amino_nitrogen_plots <- significant_feature_plots_chosen[as.character(sig_groups$amino_nitrogen)]
heme_antioxidant_plots <- significant_feature_plots_chosen[as.character(sig_groups$heme_antioxidant)]
}
#+ 3.5: Recreate Individual Feature Plots (Full) For Supplement
#- 3.5.1: Create individual plots for all significant features
significant_feature_plots_all <- plot_targeted(
  feature_table = TFT_indv,
  metadata_table = indv_plots,
  include_individual_points = TRUE,
  undo_log = TRUE,
  text_scale = 0.6,
  sig_ord_title = FALSE
)
#- 3.5.2: Make all S2 page plots (pages only, no table)
S2 <- plot_S2(
  annot_df = annot_inspection,
  plots = significant_feature_plots_all
)
#- 3.5.3: Make abbreviation tibble with S2 mapping
S2_abbrev_data <- annot_inspection %>%
  filter(abbreviated != "N") %>%
  left_join(S2$pg.row.col, by = "sig_ord") %>%
  mutate(
    `Page.Row.Column` = paste(page, row, column, sep = "."),
    `Abbreviated/Displayed Name` = short_name,
    `Longform, Other, or Isomer Name(s)` = ifelse(abbreviated == "I", isomer_names, name)
  ) %>%
  select(`Page.Row.Column`, `Abbreviated/Displayed Name`, `Longform, Other, or Isomer Name(s)`)
#- 3.5.4: Build Table
S2_abbrev_table <- plot_S2_abbrev(
  table_data = S2_abbrev_data,
  col_widths = c(1.2, 1.65, 3.575),
  header_row_ht = 0.133*2, # Taller header
  row_ht = 0.133,
  output_file = "Outputs/Figures/Raw/S2.5t.png",
  width = 6.425,
  height = 4.3,
  dpi = 1200
)
#- 3.5.5: Print page 5 in advance of table join
print_to_png(S2$pages[[5]], "S2.5i.png", width = 8.5, height = 11, dpi = 1200, output_dir = "Outputs/Figures/Raw/")
