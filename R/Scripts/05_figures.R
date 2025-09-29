#* 5: Figure Creation
#+ 5.0: Assign figures
#- 5.0.1: Figure 1 
fig1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig1.png")), interpolate = TRUE)
#- 5.0.2: Figure 2 
plsda_2A <- plsda_nosev$plot
plsda_2B <- plsda_modsev$plot
volc_2C <- volcano_nosev$volcano_plot
volc_2D <- volcano_modsev$volcano_plot
#- 5.0.3: Figure 3 
# pathway_enrichment_3A <- pathway_enrichment
# network_3B <- network_nosev
# network_3C <- network_modsev
#- 5.0.4: Figure 4 
# 4A <- pls_bar_nosev
# 4B <- superclasses_nosev
# 4C <- classes_nosev
# 4D <- pls_bar_modsev
# 4E <- superclasses_modsev
# 4F <- classes_modsev
#+ 5.1: Figure 1
Figure_1 <- patchwork::wrap_plots(
  ggplot2::ggplot() +
    ggplot2::annotation_custom(fig1, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = grid::unit(c(0, 0, 0, 0), "in")),
  blank_plot,  
  design = "
    A
    B
  ",
  heights = c(1, 1) # 50% top, 50% bottom
) +
  patchwork::plot_annotation(
    title = "Figure 1\n",
    theme = ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
      plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
    )
  )
#+ 5.2: Figure 2 
Figure_2 <- patchwork::wrap_plots(
  plsda_2A + ggplot2::labs(tag = "A") + ggplot2::theme(plot.tag.position = c(0, 0.98), plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")), 
  plsda_2B + ggplot2::labs(tag = "B") + ggplot2::theme(plot.tag.position = c(0, 0.98), plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")), 
  volc_2C + ggplot2::labs(tag = "C") + ggplot2::theme(plot.tag.position = c(0, 0.98), plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")), 
  volc_2D + ggplot2::labs(tag = "D") + ggplot2::theme(plot.tag.position = c(0, 0.98), plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")),
    # Preserve volcano legend positioning  
    legend.position.inside = c(0.02, 0.98),
    legend.justification.inside = c(0, 1)
  ),
  blank_plot, blank_plot,
  design = "
    AB
    CD
    EF
  ", # Top 40% heatmaps (A), Middle 20% PLSDAs (C,D), Bottom 40% blank plots (E,F)
  heights = c(2, 2, 2) # Equal height for all three rows
) +
  patchwork::plot_annotation(
    title = "Figure 2\n",
    theme = ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
      plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
    )
  )
print_to_png(Figure_2, "Figure 2")
