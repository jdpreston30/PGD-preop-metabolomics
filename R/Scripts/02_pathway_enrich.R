#* 2: Pathway Enrichment Analysis
#+ 2.1: Run Mummichog Ttest function ----

pathway_enrich_data <- mummichog_ttests(
  data = UFT,
  group_column = "PGD",
  output_filename = "C18_HILIC_full.csv",
  output_dir = "Outputs/mummichog_inputs/",
  group1_value = "N",
  group2_value = "Y"
)
