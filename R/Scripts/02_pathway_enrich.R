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
#- 2.3.2: Make MFN only plot
pgd_enrichment_plot_mfn <- plot_mummichog_enrichment(
  json_files = mfn_json_files,
  combine_databases = FALSE,
  p_threshold = 0.1,
  enrichment_cap = 5,
  size_range = c(3, 10),
  size_breaks = c(5, 3, 1),
  show_legend = TRUE,
  save_path = "Figures/Raw/fig2c.png",
  plot_width = 6.3,
  plot_height = 6,
  dpi = 600,
  color_scale = "rb"
)
#- 2.3.1: Create combined MFN and KEGG enrichment plot from JSON outputs
pgd_enrichment_plot_combined <- plot_mummichog_enrichment(
  json_files = combined_json_files,
  combine_databases = TRUE,
  p_threshold = 0.1,
  enrichment_cap = 5,
  size_range = c(3, 10),
  size_breaks = c(5, 3, 1),
  show_legend = TRUE,
  save_path = "Figures/Raw/S1.png",
  plot_width = 7.2,
  plot_height = 9.857,
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
  output_file = "Figures/Raw/fig2d.png",
  title = "No Severe PGD vs. Severe PGD (0-2v3)",
  node_size_range = c(4, 14),
  text_size = 4.5,
  show_legend = FALSE,
  plot_width = 10.5,
  plot_height = 12,
  dpi = 600,
  seed = 2022,
  variable_edge_thickness = TRUE,
  edge_thickness_range = c(0.3, 3),
  max_distance_from_center = 2.2,
  label_position = "above",
  show_node_numbers = FALSE,
  labels_below = c(4,1,14,5,2),  # Much cleaner than the old way!
  nudge_labels_vert = list(p12 = -2, p14= 3, p7 = 0, p2 =3.3, p9 = -1.2, p11 = -1, p3 = 0.3, p1 = 2.2, p13 = 0.5, p10 = 0.5, p6 = 0.45, p8 = -1.6),
  nudge_labels_horiz = list(p12 = 0.85, p5 = 0.55, p14 = 0.55, p7 = 1.09, p4 = 0.7, p11 = -0.15, p3 = -0.13, p1 = -0.013, p13 = -0.08, p10 = 1.08, p6 = -0.1),
  color_scale = "rb"
)
