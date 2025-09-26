#* 1: PCA and PLS-DA Analysis
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
#+ 1.2: Run PLSDA on UFT data


volcano_nosev <- make_volcano(
  data = UFT_filtered  %>% filter(PGD_grade_tier != "Non-Severe"),
  group_var = "PGD_grade_tier",
  group_levels = c("No PGD", "Severe"), 
  fc_threshold = log2(1.5), 
  p_threshold = 0.05,
  x_limits = c(-6, 6),
  y_limits = c(-0.5, 5)
)

volcano_modsev <- make_volcano(
  data = UFT_filtered %>% filter(PGD_grade_tier != "No PGD"),
  group_var = "PGD_grade_tier",
  group_levels = c("Non-Severe", "Severe"),
  fc_threshold = log2(1.5),
  p_threshold = 0.05,
  x_limits = c(-6, 6),
  y_limits = c(-0.5, 5)
)
