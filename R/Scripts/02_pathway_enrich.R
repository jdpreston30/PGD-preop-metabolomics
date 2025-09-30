#* 2: Pathway Enrichment Analysis
#+ 2.1: Run Mummichog Ttest function 
#- 2.1.1: For No PGD vs Severe
pathway_enrich_nosev <- mummichog_ttests(
  data = UFT %>% filter(PGD_grade_tier != "Mild/Mod. PGD"),
  group_column = "PGD_grade_tier",
  output_filename = "nosev.csv",
  output_dir = "Outputs/mummichog/inputs",
  group1_value = "No PGD",
  group2_value = "Severe PGD"
)
#- 2.1.2: For Mild/Mod. PGD vs Severe
pathway_enrich_modsev <- mummichog_ttests(
  data = UFT %>% filter(PGD_grade_tier != "No PGD"),
  group_column = "PGD_grade_tier",
  output_filename = "modsev.csv",
  output_dir = "Outputs/mummichog/inputs",
  group1_value = "Mild/Mod. PGD",
  group2_value = "Severe PGD"
)
#- 2.1.3: For No+Mild/Mod. PGD vs Severe
pathway_enrich_allsev <- mummichog_ttests(
  data = UFT,
  group_column = "severe_PGD",
  output_filename = "allsev.csv",
  output_dir = "Outputs/mummichog/inputs",
  group1_value = "No/Mild/Mod. PGD",
  group2_value = "Severe PGD"
)
#+ 2.2: Run Mummichog (MFN and KEGG)
#- 2.2.0: NOTE
  #! All performed externally in Metaboanalyst
#- 2.2.1: Interactive pause for external analysis
cat("\n=== EXTERNAL ANALYSIS REQUIRED ===\n")
cat("Before continuing, you must run pathway enrichment externally in MetaboAnalyst.ca\n")
cat("using the CSV files generated in section 2.1.\n\n")
cat("Type y to continue or n to stop pipeline progress: ")
user_input <- readline()
if (user_input != "y") {
  if (user_input == "n") {
    stop("Pipeline stopped by user request.")
  } else {
    stop("Invalid input. Please restart and type 'y' to continue or 'n' to stop.")
  }
}
#+ 2.3: Read in Mummichog results
#- 2.3.1: Read KEGG pathway results
{
kegg_nosev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/KEGG/nosev_pathways_KEGG.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1)
kegg_modsev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/KEGG/modsev_pathways_KEGG.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1)
kegg_allsev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/KEGG/allsev_pathways_KEGG.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1)
}
#- 2.3.2: Read MFN pathway results
{
mfn_nosev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/MFN/nosev_pathways_MFN.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1)
mfn_modsev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/MFN/modsev_pathways_MFN.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1)
mfn_allsev_pathways <- readr::read_csv(here::here("Outputs/mummichog/outputs/MFN/allsev_pathways_MFN.csv"), show_col_types = FALSE) %>%
  rename(pathway_name = ...1)
}
#+ 2.4: Pathway Enrichment Plots
source(here::here("R/Utilities/Visualization/plot_pathway_enrichment.R"))
#- 2.4.1: Create MFN enrichment plot
pgd_enrichment_plot_mfn <- plot_pathway_enrichment(
  nosev_pathways = mfn_nosev_pathways,
  modsev_pathways = mfn_modsev_pathways,
  allsev_pathways = mfn_allsev_pathways,
  p_method = "fisher",
  enrichment_cap = 5,
  size_range = c(5, 10),
  size_breaks = c(5, 3, 1),
  show_legend = TRUE,
  save_path = "Outputs/Grob/pgd_enrichment_plot_mfn.png",
  plot_width = 8,
  plot_height = 7,
  dpi = 600
)
#- 2.4.1: Create KEGG enrichment plot
pgd_enrichment_plot_kegg <- plot_pathway_enrichment(
  nosev_pathways = kegg_nosev_pathways,
  modsev_pathways = kegg_modsev_pathways,
  allsev_pathways = kegg_allsev_pathways,
  p_method = "fisher", # Could use "gamma" or "both" for multiple plots
  enrichment_cap = 8,
  size_range = c(4, 8),
  size_breaks = c(8, 6, 4, 2),
  show_legend = FALSE,
  save_path = "Outputs/Grob/pgd_enrichment_plot_kegg.png",
  plot_width = 8,
  plot_height = 7,
  dpi = 600
)
#+ 2.6: Enrichment Network Plots
#- 2.6.1: Source modular functions
source(here::here("R/Utilities/Analysis/build_enrichment_network.R"))
source(here::here("R/Utilities/Visualization/plot_enrichment_network.R"))
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
