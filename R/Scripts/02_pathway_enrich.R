#* 2: Pathway Enrichment Analysis
#+ 2.1: Run Mummichog Ttest function (no CSV outputs - direct tibble workflow)
#- 2.1.1: For No PGD vs Severe
pathway_enrich_nosev <- mummichog_ttests(
  data = UFT %>% filter(PGD_grade_tier != "Mild/Mod. PGD"),
  group_column = "PGD_grade_tier",
  group1_value = "No PGD",
  group2_value = "Severe PGD"
)
#- 2.1.2: For Mild/Mod. PGD vs Severe
pathway_enrich_modsev <- mummichog_ttests(
  data = UFT %>% filter(PGD_grade_tier != "No PGD"),
  group_column = "PGD_grade_tier",
  group1_value = "Mild/Mod. PGD",
  group2_value = "Severe PGD"
)
#- 2.1.3: For No+Mild/Mod. PGD vs Severe
pathway_enrich_allsev <- mummichog_ttests(
  data = UFT,
  group_column = "severe_PGD",
  group1_value = "No/Mild/Mod. PGD",
  group2_value = "Severe PGD"
)
#+ 2.2: Run Mummichog Analysis (using t-test results directly)
#- 2.2.1: Run Mummichog Analysis for No vs Severe (MFN database)
mummichog_nosev_mfn <- run_mummichog_analysis(
  ttest_results = pathway_enrich_nosev$results,
  output_dir = "Outputs/mummichog/nosev/MFN",
  database = "hsa_mfn",
  instrumentOpt = 5.0,
  msModeOpt = "mixed",
  force_primary_ion = "yes"
)
#- 2.2.2: Run Mummichog Analysis for No vs Severe (KEGG database)  
mummichog_nosev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_nosev$results,
  output_dir = "Outputs/mummichog/nosev/KEGG",
  database = "hsa_kegg",
  instrumentOpt = 5.0,
  msModeOpt = "mixed",
  force_primary_ion = "yes"
)
#- 2.2.3: Run Mummichog Analysis for Mild/Mod vs Severe (MFN database)
mummichog_modsev_mfn <- run_mummichog_analysis(
  ttest_results = pathway_enrich_modsev$results,
  output_dir = "Outputs/mummichog/modsev/MFN",
  database = "hsa_mfn",
  instrumentOpt = 5.0,
  msModeOpt = "mixed",
  force_primary_ion = "yes"
)
#- 2.2.4: Run Mummichog Analysis for Mild/Mod vs Severe (KEGG database)  
mummichog_modsev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_modsev$results,
  output_dir = "Outputs/mummichog/modsev/KEGG",
  database = "hsa_kegg",
  instrumentOpt = 5.0,
  msModeOpt = "mixed",
  force_primary_ion = "yes"
)
#- 2.2.5: Run Mummichog Analysis for No+Mild/Mod vs Severe (MFN database)
mummichog_allsev_mfn <- run_mummichog_analysis(
  ttest_results = pathway_enrich_allsev$results,
  output_dir = "Outputs/mummichog/allsev/MFN",
  database = "hsa_mfn",
  instrumentOpt = 5.0,
  msModeOpt = "mixed",
  force_primary_ion = "yes"
)
#- 2.2.6: Run Mummichog Analysis for No+Mild/Mod vs Severe (KEGG database)  
mummichog_allsev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_allsev$results,
  output_dir = "Outputs/mummichog/allsev/KEGG",
  database = "hsa_kegg",
  instrumentOpt = 5.0,
  msModeOpt = "mixed",
  force_primary_ion = "yes"
)
#+ 2.3: Create Pathway Enrichment Plots (using MetaboAnalystR JSON outputs)
#- 2.3.1: Define JSON file paths once
{mfn_json_files <- list(
  nosev = "Outputs/mummichog/nosev/MFN/scattermum.json",
  modsev = "Outputs/mummichog/modsev/MFN/scattermum.json",
  allsev = "Outputs/mummichog/allsev/MFN/scattermum.json"
)
kegg_json_files <- list(
  nosev = "Outputs/mummichog/nosev/KEGG/scattermum.json",
  modsev = "Outputs/mummichog/modsev/KEGG/scattermum.json",
  allsev = "Outputs/mummichog/allsev/KEGG/scattermum.json"
)
combined_json_files <- list(
  mfn = mfn_json_files,
  kegg = kegg_json_files
)}
#- 2.3.2: Make MFN only plot
pgd_enrichment_plot_mfn <- plot_mummichog_enrichment(
  json_files = mfn_json_files,
  combine_databases = FALSE,
  p_threshold = 0.05,
  enrichment_cap = 5,
  size_range = c(5, 10),
  size_breaks = c(5, 3, 1),
  show_legend = TRUE,
  save_path = "Figures/Raw/fig2a.png",
  plot_width = 8,
  plot_height = 6,
  dpi = 600
)
#- 2.3.1: Create combined MFN and KEGG enrichment plot from JSON outputs
pgd_enrichment_plot_combined <- plot_mummichog_enrichment(
  json_files = combined_json_files,
  combine_databases = TRUE,
  p_threshold = 0.05,
  enrichment_cap = 8,
  size_range = c(4, 8),
  size_breaks = c(8, 6, 4, 2),
  show_legend = TRUE,
  save_path = "Figures/Raw/S1.png",
  plot_width = 8.5,
  plot_height = 9.8,
  dpi = 600
)
#+ 2.4: Run Biological Network Analysis
#- 2.4.1: Run Network for MFN (No vs Severe)
mfn_nosev_network <- create_biological_network(
  pathway_csv = "Outputs/mummichog/nosev/MFN/mummichog_pathway_enrichment_mummichog.csv",
  min_shared_compounds = 1, 
  p_threshold = 0.1,
  max_pathways = 20,
  network_name = "mfn_nosev_biological"
)
#- 2.4.2: Run Network for MFN (Mild/Mod vs Severe)
mfn_modsev_network <- create_biological_network(
  pathway_csv = "Outputs/mummichog/modsev/MFN/mummichog_pathway_enrichment_mummichog.csv",
  min_shared_compounds = 1, 
  p_threshold = 0.1,
  max_pathways = 20,
  network_name = "mfn_modsev_biological"
)
#- 2.4.3: Run Network for MFN (No+Mild/Mod vs Severe)
mfn_allsev_network <- create_biological_network(
  pathway_csv = "Outputs/mummichog/allsev/MFN/mummichog_pathway_enrichment_mummichog.csv",
  min_shared_compounds = 1, 
  p_threshold = 0.1,
  max_pathways = 20,
  network_name = "mfn_allsev_biological"
)
#+ 2.5: Plot Biological Networks
source("R/Utilities/Helpers/clean_pathway_names_for_network.R")
source("R/Utilities/Visualization/plot_biological_network.R")
#- 2.5.1: Plot MFN Network (No vs Severe)
nosev_network_plot <- plot_biological_network(
  network_data = mfn_nosev_network,
  output_file = "Figures/Raw/biological_network_mfn_nosev.png",
  title = "No PGD vs. Severe PGD (0v3)",
  node_size_range = c(4, 14),
  text_size = 4.5,
  show_legend = FALSE,
  plot_width = 10.5,
  plot_height = 12,
  dpi = 600,
  seed = 2025,
  variable_edge_thickness = TRUE,
  edge_thickness_range = c(0.3, 3),
  max_distance_from_center = 2.2,
  label_position = "above",
  show_node_numbers = FALSE,  # Uncomment to see pathway reference numbers
  labels_below = c(4, 6, 7, 9),  # Much cleaner than the old way!
  nudge_labels_vert = list(p1 = -2, p5 = -1, p2 = 0, p3 = -2, p6 = 3.5, p9 = 3, p8 = 0),
  nudge_labels_horiz = list(p8 = -0.13, p2 = 1.18, p4 = 0.8, p5 = -0.07)
)
#- 2.5.2: Plot MFN Network (Mild/Mod vs Severe
modsev_network_plot <- plot_biological_network(
  network_data = mfn_modsev_network,
  output_file = "Figures/Raw/biological_network_mfn_modsev.png",
  title = "Mild/Mod. PGD vs. Severe PGD (1-2v3)",
  node_size_range = c(4, 14),
  text_size = 4.5,
  show_legend = FALSE,
  plot_width = 10.5,
  plot_height = 12,
  dpi = 600,
  seed = 2024,
  variable_edge_thickness = TRUE,
  edge_thickness_range = c(0.3, 3),
  max_distance_from_center = 2.2,
  label_position = "above",
  show_node_numbers = FALSE,  # Uncomment to see pathway reference numbers
  labels_below = c(3,9,6,4,8),  # Much cleaner than the old way!
  nudge_labels_vert = list(p1 = -2, p4 = 2.55, p3 = 2.9, p7 = -1.6, p11 = -2, p12 = 0.3, p10 = 0, p9 = 1.9, p6 = 1.9, p8 = 0, p5 = -2, p2 = 3),
  nudge_labels_horiz = list(p12 = 1.06, p10 = -0.12, p9 = -0.1, p8 = -.1, p2 = 0.97)
)
#- 2.5.3: Plot MFN Network (No+Mild/Mod vs Severe)
allsev_network_plot <- plot_biological_network(
  network_data = mfn_allsev_network,
  output_file = "Figures/Raw/biological_network_mfn_allsev.png",
  title = "No/Mild/Mod. PGD vs. Severe PGD (0-2v3)",
  node_size_range = c(4, 14),
  text_size = 4.5,
  show_legend = FALSE,
  plot_width = 10.5,
  plot_height = 12,
  dpi = 100,
  seed = 2022,
  variable_edge_thickness = TRUE,
  edge_thickness_range = c(0.3, 3),
  max_distance_from_center = 2.2,
  label_position = "above",
  show_node_numbers = TRUE,
  labels_below = c(4,1,14,5,2),  # Much cleaner than the old way!
  nudge_labels_vert = list(p12 = -2, p14= 3, p7 = 0, p2 =3.3),
  nudge_labels_horiz = list(p5 = 0.55, p14 = 0.55, p7 = 1.09, p2 = 0.9)
)
