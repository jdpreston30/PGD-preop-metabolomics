#* 2: Pathway Enrichment Analysis
#+ 2.1: Run Mummichog Ttest function ----
UFT_severe<- UFT %>%
  left_join(clinical_metadata %>%
    select(Patient, severe_PGD), by = "Patient") %>%
    select(Patient, severe_PGD, everything(), -PGD)
pathway_enrich_data <- mummichog_ttests(
  data = UFT,
  group_column = "PGD",
  output_filename = "C18_HILIC_full.csv",
  output_dir = "Outputs/mummichog_inputs/",
  group1_value = "N",
  group2_value = "Y"
)
pathway_enrich_data_severe <- mummichog_ttests(
  data = UFT_severe,
  group_column = "severe_PGD",
  output_filename = "C18_HILIC_full.csv",
  output_dir = "Outputs/Severe/mummichog_inputs/",
  group1_value = "N",
  group2_value = "Y"
)