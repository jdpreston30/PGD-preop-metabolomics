#* 2: Pathway Enrichment Analysis
#+ 2.1: Run Mummichog Analysis
#- 2.1.1: Run Mummichog Ttest function
pathway_enrich_allsev <- mummichog_ttests(
  data = UFT,
  group_column = "severe_PGD",
  group1_value = "No Severe PGD",
  group2_value = "Severe PGD"
)
#- 2.1.2: Run Mummichog (MFN Only)
mummichog_allsev_mfn <- run_mummichog_analysis(
  ttest_results = pathway_enrich_allsev$results,
  output_dir = "Outputs/mummichog/allsev/MFN",
  database = "hsa_mfn",
  instrumentOpt = 5.0,
  msModeOpt = "mixed",
  force_primary_ion = "yes"
)
#- 2.1.3: Run Mummichog (MFN + KEGG)
mummichog_allsev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_allsev$results,
  output_dir = "Outputs/mummichog/allsev/KEGG",
  database = "hsa_kegg",
  instrumentOpt = 5.0,
  msModeOpt = "mixed",
  force_primary_ion = "yes"
)
#+ 2.3: Create Pathway Enrichment Plots
#- 2.3.1: Define JSON file paths once
mfn_json_files <- list(
  allsev = "Outputs/mummichog/allsev/MFN/scattermum.json"
)
kegg_json_files <- list(
  allsev = "Outputs/mummichog/allsev/KEGG/scattermum.json"
)
combined_json_files <- list(
  mfn = mfn_json_files,
  kegg = kegg_json_files
)
#- 2.3.2: Import tibbles for inspection
mfn_tibbles <- map(mfn_json_files, read_mummichog_json)
kegg_tibbles <- map(kegg_json_files, read_mummichog_json)
combined_tibbles <- list(
  MFN = mfn_tibbles,
  KEGG = kegg_tibbles
)
#- 2.3.3: Make MFN inspection tibble for visualization
mfn_inspect <- mfn_tibbles$allsev %>%
  arrange(enrichment) %>%
  filter(p_value >= 1)
#- 2.3.4: Inspect combined for visualization
combined_inspection <- bind_rows(
  mfn_tibbles$allsev %>% mutate(database = "MFN"),
  kegg_tibbles$allsev %>% mutate(database = "KEGG")
) %>%
  arrange(enrichment) %>%
  filter(p_value >= 1)
#- 2.3.5: Print min and max of MFN and combined p values and enrichment for visualization scaling
cat(
  "\n", strrep("=", 60), "\n",
  "PATHWAY ENRICHMENT RANGES FOR VISUALIZATION SCALING\n",
  strrep("=", 60), "\n\n",
  "📊 MFN Database:\n",
  "   P-value range:    ", min(mfn_inspect$p_value), " to ", max(mfn_inspect$p_value), "\n",
  "   Enrichment range: ", min(mfn_inspect$enrichment), " to ", max(mfn_inspect$enrichment), "\n\n",
  "📊 Combined (MFN + KEGG):\n",
  "   P-value range:    ", min(combined_inspection$p_value), " to ", max(combined_inspection$p_value), "\n",
  "   Enrichment range: ", min(combined_inspection$enrichment), " to ", max(combined_inspection$enrichment), "\n\n",
  strrep("=", 60), "\n\n"
)
#- 2.3.6: Make MFN only plot
pgd_enrichment_plot_mfn <- plot_mummichog_enrichment(
  json_files = mfn_json_files,
  combine_databases = FALSE,
  p_threshold = 0.1,
  enrichment_cap = 5,
  size_range = c(3, 10),
  size_breaks = c(4, 3, 2, 1),
  show_legend = TRUE,
  save_path = "Outputs/Figures/Raw/fig2c.png",
  plot_width = 6.3, 
  plot_height = 5.4, #! 6.3 for 3b version
  dpi = 600,
  color_scale = "rb"
)
#- 2.3.7: Create combined MFN and KEGG enrichment plot from JSON outputs
pgd_enrichment_plot_combined <- plot_mummichog_enrichment(
  json_files = combined_json_files,
  combine_databases = TRUE,
  p_threshold = 0.1,
  enrichment_cap = 5,
  size_range = c(3, 10),
  size_breaks = c(4, 3, 2, 1),
  show_legend = TRUE,
  save_path = "Outputs/Figures/Raw/S1.png",
  plot_width = 7.2,
  plot_height = 11.14, #! 9.857 for 3b version
  dpi = 600,
  color_scale = "rb"
)
#+ 2.4: Run Biological Network Analysis
mfn_allsev_network <- create_biological_network(
  pathway_csv = "Outputs/mummichog/allsev/MFN/mummichog_pathway_enrichment_mummichog.csv",
  min_shared_compounds = 1, 
  p_threshold = 0.1,
  max_pathways = 20,
  network_name = "mfn_allsev_biological"
)
#+ 2.5: Plot Biological Networks
allsev_network_plot <- plot_biological_network(
  network_data = mfn_allsev_network,
  output_file = "Outputs/Figures/Raw/fig2d.png",
  node_size_range = c(4, 14),
  text_size = 4.5,
  show_legend = FALSE,
  plot_width = 10.5,
  plot_height = 12,
  dpi = 100,
  seed = 2017, 
  variable_edge_thickness = TRUE,
  edge_thickness_range = c(0.3, 3),
  max_distance_from_center = 1.5,
  label_position = "above",
  show_node_numbers = FALSE,
  labels_below = c(5,4, 7, 2, 12),
  nudge_labels_vert = list(p1 = -1, p3 = -1.5, p6 = -0.8, p10 = -1.75, p7 = 1, p4 = 1, p11 = 2.2, p8 = -0.75, p12 = -1, p9 = -2),
  nudge_labels_horiz = list(p1 = -0.11, p3 = -0.12, p6 = -0.075, p7 = -0.1, p4 = 1.11, p11 = 1, p8 = -0.11, p12 = 1.13, p9 = 0.6),
  color_scale = "rb"
)
