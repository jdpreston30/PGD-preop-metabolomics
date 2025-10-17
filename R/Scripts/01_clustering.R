#* 1: PCA and PLS-DA Analysis (Computation Only)
#+ 1.2: Run PLSDA on UFT data 
plsda_allsev_data <- run_PCA(
  UFT_filtered,
  group_var = "severe_PGD",
  method = "PLSDA",
  ncomp = 10
)
#+ 1.3: Run Volcano Analysis on UFT data (Computation Only)
volcano_allsev_data <- run_volcano(
  data = UFT_filtered,
  group_var = "severe_PGD",
  group_levels = c("No Severe PGD", "Severe PGD"),
  fc_threshold = log2(1.5),
  p_threshold = 0.05
)
#+ 1.4: Create Plots
#- 1.4.5: PLSDA
plsda_allsev <- plot_PCA(
  pca_results = plsda_allsev_data
)
#- 1.4.6: Volcano
volc_allsev <- plot_volcano(
  volcano_results = volcano_allsev_data,
  x_limits = c(-5, 5.36),
  y_limits = c(0, 6.71),
  down_color = "#113d6a"
)
