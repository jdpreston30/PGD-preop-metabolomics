#* 5: Plot Creation
#+ 5.1: Create Plots
#- 5.1.1: Fig. 1 Plots
fig1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig1.png")), interpolate = TRUE)
#- 5.1.2: Figure 2 
plsda_nosev <- plot_PCA(
  pca_results = plsda_nosev_data
)
plsda_modsev <- plot_PCA(
  pca_results = plsda_modsev_data
)
volc_nosev <- plot_volcano(
  volcano_results = volcano_nosev_data,
  x_limits = c(-6, 6.235),
  y_limits = c(0, 5.1)
)
volc_modsev <- plot_volcano(
  volcano_results = volcano_modsev_data,
  x_limits = c(-6, 6.235),
  y_limits = c(0, 5.1),
  down_color = "#4A5D23"  # Use green color matching Mild/Mod PGD in PCA plots
)
#+ 5.2: Assign plots for figure assembly
#- 5.2.1: Figure 1
p1A <- fig1
#- 5.2.2: Figure 2
p2A <- plsda_nosev + theme(plot.margin = grid::unit(c(0, 0, -20, 0), "cm"))
p2B <- volc_nosev + theme(plot.margin = grid::unit(c(0, 0, -20, 0), "cm"))
p2C <- plsda_modsev + theme(plot.margin = grid::unit(c(-20, 0, 0, 0), "cm"))
p2D <- volc_modsev + theme(plot.margin = grid::unit(c(-20, 0, 0, 0), "cm"))

# Figure_2 <- (p2A + p2B) /
#   (p2C + p2D) +
#   patchwork::plot_layout(heights = c(1, 1)) &
#   theme(plot.margin = margin(0, 0, 0, 0))
#- 5.2.3: Figure 3
# p3A <- pathway_enrichment
# p3B <- network_nosev
# p3C <- network_modsev
#- 5.2.4: Figure 4 
# p4A <- pls_bar_nosev
# p4B <- superclasses_nosev
# p4C <- classes_nosev
# p4D <- pls_bar_modsev
# p4E <- superclasses_modsev
# p4F <- classes_modsev