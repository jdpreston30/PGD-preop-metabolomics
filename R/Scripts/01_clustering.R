#* 1: PCA and PLS-DA Analysis
#+ 1.1: Run Heatmap
heatmap_result <- make_heatmap(
  data = UFT_filtered,
  group_var = "PGD_grade_tier",
  patient_var = "Patient",
  group_colors = c("Severe" = "#800017", "No PGD" = "#113d6a", "Non-Severe" = "#4A5D23"),
  top_features = 250,
  feature_selector = "variance",
  group_levels = c("Severe", "Non-Severe", "No PGD")
)
#+ 1.2: Run PLSDA on UFT data 
#- 1.2.1: For No PGD vs Severe ----
plsda_nosev <- make_PCA(
  UFT_filtered  %>% filter(PGD_grade_tier != "Non-Severe"),
  group_var = "PGD_grade_tier",
  method = "PLSDA",
  ellipse_colors = c("Severe" = "#D8919A", "No PGD" = "#87A6C7", "Non-Severe" = "#9CAF88"),
  point_colors = c("Severe" = "#800017", "No PGD" = "#113d6a", "Non-Severe" = "#4A5D23"),
  show_patient_labels = FALSE,
  label_size = 2
)
#- 1.2.2: For No PGD vs Severe ----
plsda_modsev <- make_PCA(
  UFT_filtered %>% filter(PGD_grade_tier != "No PGD"),
  group_var = "PGD_grade_tier",
  method = "PLSDA",
  ellipse_colors = c("Severe" = "#D8919A", "No PGD" = "#87A6C7", "Non-Severe" = "#9CAF88"),
  point_colors = c("Severe" = "#800017", "No PGD" = "#113d6a", "Non-Severe" = "#4A5D23"),
  show_patient_labels = FALSE,
  label_size = 2
)
