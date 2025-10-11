#* 4: Targeted and Quantified Features Analysis
#+ 4.1: T-tests for all metabolomic features against PGD status 

  

  left_join(TFT_confirmed_key %>% select(-c(MMD, identified_name, isomer)), by = "feature") %>%
  arrange(feature) %>%
  filter(include == "Y") %>%
  distinct(feature, .keep_all = TRUE) %>%
  group_by(KEGG) %>%
  filter(!(MMD == "Y" & n() > 1) | (MMD == "Y" & n() > 1 & p_value == min(p_value))) %>%
  ungroup() %>%
  arrange(p_value) %>%
  mutate(sig_ord = row_number(), log2FC = log2(fold_change)) %>%
  select(sig_ord, short_name, long_name = identified_name, isomer_names, KEGG, p_value, p_value_fdr, log2FC, everything(), -include)
#- 3.2.2: Save Excel
write_xlsx(ttest_annot_pared, "Outputs/data_not_shown/annot_inspection.xlsx")
#- 3.2.3: Pull Names
include_metabolites_annot <- ttest_annot_pared %>%
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
  header_row_ht = 0.133 * 2, # Taller header
  row_ht = 0.133,
  output_file = "Outputs/Figures/Raw/S2.4t.png",
  width = 5.5,
  height = 3.8,
  dpi = 1200
)
#- 3.5.5: Print page 4 (final page with 9 plots)
print_to_png(S2$pages[[4]], "S2.4i.png", width = 8.5, height = 11, dpi = 200, output_dir = "Outputs/Figures/Raw/")



#- 3.1.2: Remove low detects (things that were over 20% missingness and thus half min interp) Results
TFT_conf_ttests_low_det_removed <- TFT_conf_ttests %>%
  filter(low_detect_likely == "N")




#- 4.1.3: Filter to significant values; inspect; join with MSMICA key info
inspect_TFT_conf <- TFT_conf_ttests_low_det_removed %>%
  mutate(
    log2FC = log2(fold_change),
    sig_ord = row_number(),
    in_annot = ifelse(feature %in% feature_ttest_results$feature, "Y", "N"),
    annot_sig = ifelse(feature %in% annot_inspection$feature, "Y", "N")
  ) %>%
  left_join(feature_ttest_results %>% select(feature, pva = p_value), by = "feature") %>%
  arrange(p_value) %>%
  select(feature, annot_name, identified_name, fca,	p_value, pva) %>%
  filter(!is.na(annot_name))
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
#- 4.3.3: Subset TFT_annot to the chosen ones; rename
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

