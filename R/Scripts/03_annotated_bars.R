#* 3: Annotated Features Analsyis
#+ 3.1: T-tests for all metabolomic features against PGD status
#- 3.1.1: Run T-test function for combined TFT
TFT_combined_results <- run_targeted_ttests(
  feature_table = TFT_combined,
  grouping_var = "severe_PGD",
  fc_ref_group = "No Severe PGD"
)
#- 3.1.2: Mark if in library; filter to sig
TFT_combined_results_marked <- TFT_combined_results %>%
  left_join(TFT_merged_features, by = "feature") %>%
  select(lib_conf, source, everything()) %>%
  filter(p_value < 0.05) %>%
  arrange(desc(source)) %>%
  left_join(TFT_annot_key, by = "feature")



  print(TFT_combined_results_marked, n = Inf)
#+ 3.2: Inspect and Clean Features
#- 3.2.1: Join relevant QC info; filter to chosen from QC; filter MMD to lower p-value; leftjoin with confirmed name; save
ttest_annot_pared <- TFT_combined_results_marked %>%
  left_join(TFT_annot_key %>% select(-c(MMD, identified_name, isomer)), by = "feature") %>%
  arrange(feature) %>%
  filter(include == "Y") %>%
  distinct(feature, .keep_all = TRUE) %>%
  group_by(KEGG) %>%
  filter(!(MMD == "Y" & n() > 1) | (MMD == "Y" & n() > 1 & p_value == min(p_value))) %>%
  ungroup() %>%
  arrange(p_value) %>%
  mutate(sig_ord = row_number()) %>%
  left_join(ttest_conf_pared %>% select(feature, confirmed_name = identified_name), by = "feature") %>%
  select(sig_ord, confirmed_name, short_name, long_name = identified_name, isomer_names, KEGG, p_value, p_value_fdr, log2FC, everything(), -include) %>%
  arrange(confirmed_name) %>%
  select(feature, sig_ord:long_name) %>%
  left_join(TFT_confirmed_key %>% select(feature, library_mz, library_rt), by = "feature") %>%
  distinct(confirmed_name, .keep_all = TRUE) %>%
  filter(!is.na(confirmed_name)) %>%
  arrange(sig_ord)
print(ttest_annot_pared, n = Inf)
write.csv(ttest_annot_pared, "Outputs/data_not_shown/annot_inspection.csv", row.names = FALSE)
#- 3.2.2: Save Excel
write_xlsx(ttest_annot_pared, "Outputs/data_not_shown/annot_inspection.xlsx")
#- 3.2.3: Pull Names
include_metabolites_annot <- ttest_annot_pared  %>%
  pull(sig_ord)
#- 3.2.4: Pull Features
include_feature_annot <- ttest_annot_pared %>%
  pull(feature)
#- 3.2.5: Subset TFT_annot to the chosen ones
TFT_annot_chosen <- TFT_annot %>%
  select(severe_PGD, all_of(include_feature_annot))
#- 3.2.6: Pull Metadata for Individual Plots
TFT_annot_metadata <- ttest_annot_pared %>%
  select(sig_ord, short_name, long_name, p_value, p_value_fdr, log2FC, feature, abbreviated)
#+ 3.3: Visualize diverging bars
#- 3.3.1: Filter Data to 2 FC
diverging_data_annot <- ttest_annot_pared %>%
  filter(abs(log2FC) >= log2(1.5)) %>%
  arrange(log2FC)
#- 3.3.2: Create diverging bar plot
diverging_plot <- plot_diverging_bars(
  results_tibble = diverging_data_annot,
  max_features = 100,
  text_scale = 0.9
)
#+ 3.4: Visualize individual feature plots
#- 3.4.1: Create individual plots for all significant features
significant_feature_plots_chosen <- plot_targeted(
  feature_table = TFT_annot_chosen,
  metadata_table = TFT_annot_metadata,
  include_individual_points = TRUE,
  undo_log = TRUE,
  text_scale = 0.6,
  sig_ord_title = FALSE
)
#- 3.4.2: Inspect overall data to choose representative
print(TFT_annot_metadata %>% select(-feature), n = Inf)
#- 3.4.2: Choose targeted to display
sig_groups <- list(
  redox_cofactor   = c(2, 6, 7, 67),
  amino_nitrogen   = c(1, 19, 55, 66),
  lipid_remodeling = c(4, 44, 47, 59),
  heme_antioxidant = c(21, 48)
)
#- 3.4.6:  Create grouped plot lists
{
redox_cofactor_plots <- significant_feature_plots_chosen[as.character(sig_groups$redox_cofactor)]
lipid_remodeling_plots <- significant_feature_plots_chosen[as.character(sig_groups$lipid_remodeling)]
amino_nitrogen_plots <- significant_feature_plots_chosen[as.character(sig_groups$amino_nitrogen)]
heme_antioxidant_plots <- significant_feature_plots_chosen[as.character(sig_groups$heme_antioxidant)]
}
#+ 3.5: Recreate Individual Feature Plots (Full) For Supplement
#- 3.5.1: Create individual plots for all significant features
significant_feature_plots_all <- plot_targeted(
  feature_table = TFT_annot_chosen,
  metadata_table = TFT_annot_metadata,
  include_individual_points = TRUE,
  undo_log = TRUE,
  text_scale = 0.6,
  sig_ord_title = FALSE
)
#- 3.5.2: Make all S2 page plots (pages only, no table)
S2 <- plot_S2(
  annot_df = ttest_annot_pared,
  plots = significant_feature_plots_all
)
#- 3.5.3: Make abbreviation tibble with S2 mapping
S2_abbrev_data <- ttest_annot_pared %>%
  filter(abbreviated %in% c("Y", "I")) %>%
  left_join(S2$pg.row.col, by = "sig_ord") %>%
  mutate(
    `Page.Row.Column` = paste(page, row, column, sep = "."),
    `Abbreviated/Displayed Name` = short_name,
    `Longform, Other, or Isomer Name(s)` = ifelse(abbreviated == "I", isomer_names, long_name)
  ) %>%
  select(`Page.Row.Column`, `Abbreviated/Displayed Name`, `Longform, Other, or Isomer Name(s)`)
#- 3.5.4: Build Table
S2_abbrev_table <- plot_S2_abbrev(
  table_data = S2_abbrev_data,
  col_widths = c(1.2, 1.65, 2.55),
  header_row_ht = 0.133*2, # Taller header
  row_ht = 0.133,
  output_file = "Outputs/Figures/Raw/S2.4t.png",
  width = 5.5,
  height = 3.8,
  dpi = 1200
)
#- 3.5.5: Print page 4 (final page with 9 plots)
print_to_png(S2$pages[[4]], "S2.4i.png", width = 8.5, height = 11, dpi = 200, output_dir = "Outputs/Figures/Raw/")
