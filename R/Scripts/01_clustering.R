#* 1: Clustering and Differential Analysis
#' Performs PLS-DA clustering analysis on untargeted feature table (UFT).
#' Conducts volcano plot analysis comparing severe PGD vs no severe PGD groups.
#' Creates visualization objects for PLS-DA scores and volcano plots.
#+ 1.1: Run PLSDA on UFT data 
plsda_allsev_data <- run_PCA(
  UFT_filtered,
  group_var = "severe_PGD",
  method = "PLSDA",
  ncomp = 10
)
#+ 1.2: Run Volcano Analysis on UFT data (Computation Only)
volcano_allsev_data <- run_volcano(
  data = UFT_filtered,
  group_var = "severe_PGD",
  group_levels = c("No Severe PGD", "Severe PGD"),
  fc_threshold = log2(1.5),
  p_threshold = 0.05
)
#+ 1.3: Create Plots
#- 1.3.1: PLSDA
plsda_allsev <- plot_PCA(
  pca_results = plsda_allsev_data
)
#- 1.3.2: Volcano
volc_allsev <- plot_volcano(
  volcano_results = volcano_allsev_data,
  x_limits = c(-5, 5.36),
  y_limits = c(0, 6.79),
  down_color = "#113d6a"
)
