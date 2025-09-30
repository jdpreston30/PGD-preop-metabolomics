#* 2: Pathway Enrichment Analysis
#+ 2.1: Run Mummichog Ttest function 
pathway_enrich_nosev <- mummichog_ttests(
  data = UFT %>% filter(PGD_grade_tier != "Mild/Mod. PGD"),
  group_column = "PGD",
  output_filename = "C18_HILIC_nosev.csv",
  output_dir = "Outputs/mummichog_inputs/",
  group1_value = "N",
  group2_value = "Y"
)
pathway_enrich_modsev <- mummichog_ttests(
  data = UFT %>% filter(PGD_grade_tier != "No PGD"),
  group_column = "severe_PGD",
  output_filename = "C18_HILIC_modsev.csv",
  output_dir = "Outputs/Severe/mummichog_inputs/",
  group1_value = "N",
  group2_value = "Y"
)