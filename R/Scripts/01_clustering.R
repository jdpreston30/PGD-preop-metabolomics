#* 1: PCA and PLS-DA Analysis
#+ 1.2: Run PLSDA on UFT data 
#- 1.2.1: For No PGD vs Severe 
plsda_nosev <- make_PCA(
  UFT_filtered  %>% filter(PGD_grade_tier != "Mild/Moderate PGD"),
  group_var = "PGD_grade_tier",
  method = "PLSDA",
  show_patient_labels = FALSE,
  label_size = 2
)
#- 1.2.2: For No PGD vs Severe 
plsda_modsev <- make_PCA(
  UFT_filtered %>% filter(PGD_grade_tier != "No PGD"),
  group_var = "PGD_grade_tier",
  method = "PLSDA",
  show_patient_labels = FALSE,
  label_size = 2
)
#+ 1.2: Run PLSDA on UFT data
#- 1.2.1: For No PGD vs Severe 
volcano_nosev <- make_volcano(
  data = UFT_filtered  %>% filter(PGD_grade_tier != "Mild/Moderate PGD"),
  group_var = "PGD_grade_tier",
  group_levels = c("No PGD", "Severe PGD"),
  fc_threshold = log2(1.5),
  p_threshold = 0.05,
  x_limits = c(-6, 6),
  y_limits = c(0, 5)
)
#- 1.2.2: For Moderate PGD vs Severe 
volcano_modsev <- make_volcano(
  data = UFT_filtered %>% filter(PGD_grade_tier != "No PGD"),
  group_var = "PGD_grade_tier",
  group_levels = c("Mild/Moderate PGD", "Severe PGD"),
  fc_threshold = log2(1.5),
  p_threshold = 0.05,
  x_limits = c(-6, 6),
  y_limits = c(0, 5)
)
