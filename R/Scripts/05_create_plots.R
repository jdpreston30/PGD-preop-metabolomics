#* 5: Plot Creation
#+ 5.1: Create Fig. 1 Plots
fig1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig1.png")), interpolate = TRUE)
#+ 5.2: Create Fig. 2 Plots
#- 5.2.1: For No PGD vs Severe PLSDA
plsda_nosev <- plot_PCA(
  pca_results = plsda_nosev_data
)
#- 5.2.2: For Moderate vs Severe PLSDA
plsda_modsev <- plot_PCA(
  pca_results = plsda_modsev_data
)
#- 5.2.3: For No PGD vs Severe Volcano
volc_nosev <- plot_volcano(
  volcano_results = volcano_nosev_data,
  x_limits = c(-6, 6.435),
  y_limits = c(0, 6.1),
)
#- 5.2.4: For Moderate vs Severe Volcano
volc_modsev <- plot_volcano(
  volcano_results = volcano_modsev_data,
  x_limits = c(-6, 6.435),
  y_limits = c(0, 6.1),
  down_color = "#be5010ff"  
)
#- 5.2.5: For No+Mild/Mod. PGD vs Severe PLSDA
plsda_allsev <- plot_PCA(
  pca_results = plsda_allsev_data
)
#- 5.2.6: For No+Mild/Mod. PGD vs Severe Volcano
volc_allsev <- plot_volcano(
  volcano_results = volcano_allsev_data,
  x_limits = c(-6, 6.435),
  y_limits = c(0, 6.1),
  down_color = "#4A5D23"
)
#+ 5.2: Assign plots for figure assembly
#- 5.2.1: Figure 1
p1A <- fig1
#- 5.2.2: Figure 2
p2A <- plsda_nosev 
p2B <- volc_nosev 
p2C <- plsda_modsev
p2D <- volc_modsev 
p2E <- plsda_allsev
p2F <- volc_allsev
#- 5.2.3: Figure 3
p3A <- pathway_enrichment
p3B <- network_nosev
p3C <- network_modsev
p3D <- network_allsev
#- 5.2.4: Figure 4 
# p4A <- pls_bar_nosev
# p4B <- superclasses_nosev
# p4C <- classes_nosev
# p4D <- pls_bar_modsev
# p4E <- superclasses_modsev
# p4F <- classes_modsev