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
#+ 2.2: Run Mummichog Analysis (Using MetaboAnalystR)
#- 2.2.1: Run Mummichog Analysis for No vs Severe (MFN database)
mummichog_nosev_mfn <- run_mummichog_analysis(
  ttest_results = pathway_enrich_nosev$results,
  analysis_name = "nosev",
  database = "hsa_mfn",
  output_base_dir = "Outputs/mummichog",
  ppm_tolerance = 5,
  rt_units = "seconds"
  # Uses default dynamic p-value threshold (top 10% of peaks)
)
#- 2.2.2: Run Mummichog Analysis for No vs Severe (KEGG database)  
mummichog_nosev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_nosev$results,
  analysis_name = "nosev", 
  database = "hsa_kegg",
  output_base_dir = "Outputs/mummichog",
  ppm_tolerance = 5,
  rt_units = "seconds"
  # Uses default dynamic p-value threshold (top 10% of peaks)
)
#- 2.2.3: Run Mummichog Analysis for Mild/Mod vs Severe (MFN database)
mummichog_modsev_mfn <- run_mummichog_analysis(
  ttest_results = pathway_enrich_modsev$results,
  analysis_name = "modsev",
  database = "hsa_mfn",
  output_base_dir = "Outputs/mummichog",
  ppm_tolerance = 5,
  rt_units = "seconds"
  # Uses default dynamic p-value threshold (top 10% of peaks)
)
#- 2.2.4: Run Mummichog Analysis for Mild/Mod vs Severe (KEGG database)  
mummichog_modsev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_modsev$results,
  analysis_name = "modsev", 
  database = "hsa_kegg",
  output_base_dir = "Outputs/mummichog",
  ppm_tolerance = 5,
  rt_units = "seconds"
  # Uses default dynamic p-value threshold (top 10% of peaks)
)
#- 2.2.5: Run Mummichog Analysis for No+Mild/Mod vs Severe (MFN database)
mummichog_allsev_mfn <- run_mummichog_analysis(
  ttest_results = pathway_enrich_allsev$results,
  analysis_name = "allsev",
  database = "hsa_mfn",
  output_base_dir = "Outputs/mummichog",
  ppm_tolerance = 5,
  rt_units = "seconds"
  # Uses default dynamic p-value threshold (top 10% of peaks)
)
#- 2.2.6: Run Mummichog Analysis for No+Mild/Mod vs Severe (KEGG database)  
mummichog_allsev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_allsev$results,
  analysis_name = "allsev", 
  database = "hsa_kegg",
  output_base_dir = "Outputs/mummichog",
  ppm_tolerance = 5,
  rt_units = "seconds"
  # Uses default dynamic p-value threshold (top 10% of peaks)
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
#+ 2.4: Create Enrichment Network Plot