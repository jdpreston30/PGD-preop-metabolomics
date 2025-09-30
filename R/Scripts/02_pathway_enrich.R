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
library(MetaboAnalystR)

# Create output directories for MetaboAnalystR results
dir.create("Outputs/MetaboAnalystR", showWarnings = FALSE, recursive = TRUE)
dir.create("Outputs/MetaboAnalystR/nosev", showWarnings = FALSE, recursive = TRUE)
dir.create("Outputs/MetaboAnalystR/nosev/MFN", showWarnings = FALSE, recursive = TRUE)
dir.create("Outputs/MetaboAnalystR/nosev/KEGG", showWarnings = FALSE, recursive = TRUE)
# Store original working directory
original_wd <- getwd()
# MFN Analysis
cat("Running MFN analysis...\n")
setwd("Outputs/MetaboAnalystR/nosev/MFN")
mSet_mfn <- InitDataObjects("mass_all", "mummichog", FALSE, 150) %>%
  SetPeakFormat("rmp") %>%
  UpdateInstrumentParameters(5.0, "mixed", "yes", 0.02) %>%
  Read.PeakListData("../../../../Outputs/mummichog/inputs/nosev.csv") %>%
  SanityCheckMummichogData() %>%
  SetPeakEnrichMethod("mum", "v2") %>%
  SetMummichogPval(0.1) %>%
  PerformPSEA("hsa_mfn", "current", 3, 100) %>%
  PlotPeaks2Paths("metaboanalyst_mfn_", "png", 150, width=NA)
setwd(original_wd)  # Return to original directory

# KEGG Analysis  
cat("Running KEGG analysis...\n")
setwd("Outputs/MetaboAnalystR/nosev/KEGG")
mSet_kegg <- InitDataObjects("mass_all", "mummichog", FALSE, 150) %>%
  SetPeakFormat("rmp") %>%
  UpdateInstrumentParameters(5.0, "mixed", "yes", 0.02) %>%
  Read.PeakListData("../../../../Outputs/mummichog/inputs/nosev.csv") %>%
  SanityCheckMummichogData() %>%
  SetPeakEnrichMethod("mum", "v2") %>%
  SetMummichogPval(0.1) %>%
  PerformPSEA("hsa_kegg", "current", 3, 100) %>%
  PlotPeaks2Paths("metaboanalyst_kegg_", "png", 150, width=NA)
setwd(original_wd)  # Return to original directory

#+ 2.3: Read in Mummichog results
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
