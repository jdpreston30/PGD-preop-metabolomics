#* 1: PCA and PLS-DA Analysis (Computation Only)
#+ 1.2: Run PLSDA on UFT data 
#- 1.2.1: For No PGD vs Severe 
plsda_nosev_data <- run_PCA(
  UFT_filtered  %>% filter(PGD_grade_tier != "Mild/Mod. PGD"),
  group_var = "PGD_grade_tier",
  method = "PLSDA",
  ncomp = 10
)
#- 1.2.2: For Mild/Mod. PGD vs Severe 
plsda_modsev_data <- run_PCA(
  UFT_filtered %>% filter(PGD_grade_tier != "No PGD"),
  group_var = "PGD_grade_tier",
  method = "PLSDA",
  ncomp = 10
)
#- 1.2.3: For No+Mild/Mod. PGD vs Severe
plsda_allsev_data <- run_PCA(
  UFT_filtered,
  group_var = "severe_PGD",
  method = "PLSDA",
  ncomp = 10
)
#+ 1.3: Run Volcano Analysis on UFT data (Computation Only)
#- 1.3.1: For No PGD vs Severe 
volcano_nosev_data <- run_volcano(
  data = UFT_filtered  %>% filter(PGD_grade_tier != "Mild/Mod. PGD"),
  group_var = "PGD_grade_tier",
  group_levels = c("No PGD", "Severe PGD"),
  fc_threshold = log2(1.5),
  p_threshold = 0.05
)
#- 1.3.2: For Moderate PGD vs Severe 
volcano_modsev_data <- run_volcano(
  data = UFT_filtered %>% filter(PGD_grade_tier != "No PGD"),
  group_var = "PGD_grade_tier",
  group_levels = c("Mild/Mod. PGD", "Severe PGD"),
  fc_threshold = log2(1.5),
  p_threshold = 0.05
)
#- 1.3.3: For No+Mild/Mod. PGD vs Severe
volcano_allsev_data <- run_volcano(
  data = UFT_filtered,
  group_var = "severe_PGD",
  group_levels = c("No/Mild/Mod. PGD", "Severe PGD"),
  fc_threshold = log2(1.5),
  p_threshold = 0.05
)