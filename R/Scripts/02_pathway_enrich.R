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
  output_base_dir = "Outputs/mummichog/outputs",
  ppm_tolerance = 5,
  p_threshold = 0.05
)
#- 2.2.2: Run Mummichog Analysis for No vs Severe (KEGG database)  
mummichog_nosev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_nosev$results,
  analysis_name = "nosev", 
  database = "hsa_kegg",
  output_base_dir = "Outputs/mummichog/outputs",
  ppm_tolerance = 5,
  p_threshold = 0.05
)

#- 2.2.3: Run Mummichog Analysis for Mild/Mod vs Severe (MFN database)
mummichog_modsev_mfn <- run_mummichog_analysis(
  ttest_results = pathway_enrich_modsev$results,
  analysis_name = "modsev",
  database = "hsa_mfn",
  output_base_dir = "Outputs/mummichog/outputs",
  ppm_tolerance = 5,
  p_threshold = 0.05
)

#- 2.2.4: Run Mummichog Analysis for Mild/Mod vs Severe (KEGG database)  
mummichog_modsev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_modsev$results,
  analysis_name = "modsev", 
  database = "hsa_kegg",
  output_base_dir = "Outputs/mummichog/outputs",
  ppm_tolerance = 5,
  p_threshold = 0.05
)

#- 2.2.5: Run Mummichog Analysis for No+Mild/Mod vs Severe (MFN database)
mummichog_allsev_mfn <- run_mummichog_analysis(
  ttest_results = pathway_enrich_allsev$results,
  analysis_name = "allsev",
  database = "hsa_mfn",
  output_base_dir = "Outputs/mummichog/outputs",
  ppm_tolerance = 5,
  p_threshold = 0.05
)

#- 2.2.6: Run Mummichog Analysis for No+Mild/Mod vs Severe (KEGG database)  
mummichog_allsev_kegg <- run_mummichog_analysis(
  ttest_results = pathway_enrich_allsev$results,
  analysis_name = "allsev", 
  database = "hsa_kegg",
  output_base_dir = "Outputs/mummichog/outputs",
  ppm_tolerance = 5,
  p_threshold = 0.05
)
#+ 2.3: Read in Mummichog results (traditional approach - can be replaced by MetaboAnalystR results above)
#- 2.3.1: Read KEGG pathway results
{
kegg_nosev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/KEGG/nosev_pathways_KEGG.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1) %>%
  mutate(pathway_name = clean_pathway_names(pathway_name))
kegg_modsev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/KEGG/modsev_pathways_KEGG.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1) %>%
  mutate(pathway_name = clean_pathway_names(pathway_name))
kegg_allsev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/KEGG/allsev_pathways_KEGG.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1) %>%
  mutate(pathway_name = clean_pathway_names(pathway_name))
}
#- 2.3.2: Read MFN pathway results
{
mfn_nosev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/MFN/nosev_pathways_MFN.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1) %>%
  mutate(pathway_name = clean_pathway_names(pathway_name))
mfn_modsev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/MFN/modsev_pathways_MFN.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1) %>%
  mutate(pathway_name = clean_pathway_names(pathway_name))
mfn_allsev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/MFN/allsev_pathways_MFN.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1) %>%
  mutate(pathway_name = clean_pathway_names(pathway_name))
}
#+ 2.6: Enrichment Network Plots
#- 2.6.2: No vs Severe PGD KEGG Network
kegg_nosev_network_data <- kegg_nosev_pathways %>%
  filter(`P(Fisher)` < 0.05) %>%
  mutate(
    pathway_ID = pathway_name,
    enrichment_factor = Hits.sig / Expected,
    p_value = as.numeric(`P(Fisher)`)
  ) %>%
  select(pathway_ID, pathway_name, enrichment_factor, p_value)

# Build graph data
kegg_nosev_graph_data <- build_enrichment_network(
  kegg_nosev_network_data,
  edge_thresh = 0.05,
  prefer_hsa = TRUE,
  seed = 123
)

# Create plot
kegg_nosev_network_plot <- plot_enrichment_network(
  graph_data = kegg_nosev_graph_data,
  save_path = "Outputs/Grob/kegg_nosev_network.png",
  plot_title = "No vs. Severe PGD KEGG Network",
  width = 10, height = 10, dpi = 600,
  show_enrichment = FALSE
)

#- 2.6.3: Mild/Mod vs Severe PGD KEGG Network
kegg_modsev_network_data <- kegg_modsev_pathways %>%
  filter(`P(Fisher)` < 0.05) %>%
  mutate(
    pathway_ID = pathway_name,
    enrichment_factor = Hits.sig / Expected,
    p_value = as.numeric(`P(Fisher)`)
  ) %>%
  select(pathway_ID, pathway_name, enrichment_factor, p_value)

# Build graph data
kegg_modsev_graph_data <- build_enrichment_network(
  kegg_modsev_network_data,
  edge_thresh = 0.05,
  prefer_hsa = TRUE,
  seed = 123
)

# Create plot
kegg_modsev_network_plot <- plot_enrichment_network(
  graph_data = kegg_modsev_graph_data,
  save_path = "Outputs/Grob/kegg_modsev_network.png",
  plot_title = "Mild/Mod vs. Severe PGD KEGG Network",
  width = 10, height = 10, dpi = 600,
  show_enrichment = FALSE
)

#- 2.6.4: No+Mild/Mod vs Severe PGD KEGG Network
kegg_allsev_network_data <- kegg_allsev_pathways %>%
  filter(`P(Fisher)` < 0.05) %>%
  mutate(
    pathway_ID = pathway_name,
    enrichment_factor = Hits.sig / Expected,
    p_value = as.numeric(`P(Fisher)`)
  ) %>%
  select(pathway_ID, pathway_name, enrichment_factor, p_value)

# Build graph data
kegg_allsev_graph_data <- build_enrichment_network(
  kegg_allsev_network_data,
  edge_thresh = 0.05,
  prefer_hsa = TRUE,
  seed = 123
)

# Create plot
kegg_allsev_network_plot <- plot_enrichment_network(
  graph_data = kegg_allsev_graph_data,
  save_path = "Outputs/Grob/kegg_allsev_network.png",
  plot_title = "No+Mild/Mod vs. Severe PGD KEGG Network",
  width = 10, height = 10, dpi = 600,
  show_enrichment = FALSE
)
