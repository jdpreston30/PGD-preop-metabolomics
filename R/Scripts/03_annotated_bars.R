#* 3: Annotated Features Analsyis
#+ 3.1: T-tests for all metabolomic features against PGD status
#- 3.1.1: Run T-test function for combined TFT
TFT_combined_results <- run_targeted_ttests(
  feature_table = TFT_combined,
  grouping_var = "severe_PGD",
  fc_ref_group = "No Severe PGD"
)
#- 3.1.2: Subset to sig chosen (TFT_QC)
source("R/Utilities/Helpers/metabolite_sentence_case.R")
TFT_sig_metadata <- TFT_combined_results %>%
  filter(feature %in% TFT_QC$feature) %>%
  left_join(TFT_QC, by = "feature") %>%
  mutate(
    display_name = map2_chr(display_name, abbrev, metabolite_sentence_case)
  ) %>%
  select(display_name, everything())
#- 3.1.3: Create subsetted feature table
TFT_combined_chosen <- TFT_combined %>%
  select(Patient, severe_PGD, all_of(TFT_sig_metadata$feature))
#+ 3.3: Visualize diverging bars
#- 3.3.1: Create diverging bar plot with FC threshold
diverging_plot <- plot_diverging_bars(
  results_tibble = TFT_sig_metadata,
  max_features = 100,
  text_scale = 0.9,
  fc_threshold = 1.5
)
#+ 3.4: Visualize individual feature plots
#- 3.4.1: Create individual plots for all significant features
significant_feature_plots_chosen <- plot_targeted(
  feature_table = TFT_combined_chosen,
  metadata_table = TFT_sig_metadata,
  include_individual_points = TRUE,
  undo_log = TRUE,
  text_scale = 0.6,
  sig_ord_title = FALSE
)
#- 3.4.2: Inspect overall data to choose representative
# write_xlsx(TFT_sig_metadata %>% select(sig_ord, display_name, long_name, note, p_value, log2FC), "inspect.xlsx")
#- 3.4.2: Choose targeted to display
sig_groups <- list(
  nitrogen   = c(1, 11, 12, 15, 59, 65),
  lipid = c(3, 44, 47, 62),
  redox = c(2, 4, 41, 70)
)
#- 3.4.6:  Create grouped plot lists
{
nitrogen_plots <- significant_feature_plots_chosen[as.character(sig_groups$nitrogen)]
lipid_plots <- significant_feature_plots_chosen[as.character(sig_groups$lipid)]
redox_plots <- significant_feature_plots_chosen[as.character(sig_groups$redox)]
}
#+ 3.5: Recreate Individual Feature Plots (Full) For Supplement
#- 3.5.1: Make all S2 page plots (pages only, no table)
S2 <- plot_S2(
  annot_df = TFT_sig_metadata,
  plots = significant_feature_plots_chosen,
  y_from = 7.75, 
  y_to = 0.715
)
#- 3.5.2: Make footnotes table
S2_footnotes <- TFT_sig_metadata %>%
  left_join(S2$pg.row.col, by = "sig_ord") %>%
  filter(!is.na(note)) %>%
  mutate(
    `Figure.Row.Column` = paste("2",page, row, column, sep = "."),
    `Abbreviated/Displayed Name` = display_name,
    `Footnote` = note,
  ) %>%
  select(`Figure.Row.Column`, `Abbreviated/Displayed Name`, `Footnote`)
#- 3.5.3: Build Footnotes Table
S2_footnotes_table <- plot_S2_abbrev(
  table_data = S2_footnotes,
  col_widths = c(0.8, 1.1, 2.55),
  header_row_ht = 0.09*1.5, # Taller header
  row_ht = 0.09,
  output_file = "Outputs/Figures/Raw/S2.5tf.png",
  width = 7,
  height = 1.3,
  dpi = 1200
)
#- 3.5.4: Make abbreviation tibble with S2 mapping
S2_abbrev_data <- TFT_sig_metadata %>%
  left_join(S2$pg.row.col, by = "sig_ord") %>%
  mutate(
    `Figure.Row.Column` = paste("2", page, row, column, sep = "."),
    `Abbreviated/Displayed Name` = display_name,
    `Longform, Other, or Isomer Name(s)` = long_name,
    `Adduct` = adduct,
  ) %>%
  mutate(across(everything(), ~ifelse(is.na(.), "-", .))) %>%
  select(`Figure.Row.Column`, `Abbreviated/Displayed Name`, `Longform, Other, or Isomer Name(s)`, `Adduct`)
#- 3.5.5: Build Table (Abbreviations)
S2_abbrev_table <- plot_S2_abbrev(
  table_data = S2_abbrev_data,
  col_widths = c(0.8, 1.1, 1.95, 0.6),
  header_row_ht = 0.09*1.5, # Taller header
  row_ht = 0.09,
  output_file = "Outputs/Figures/Raw/S2.5ta.png",
  width = 7,
  height = 7.75,
  dpi = 1200
)
