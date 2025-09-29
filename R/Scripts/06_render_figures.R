#* 6 Render Figures

#+ 6.1: Figure 1
Figure_1 <- patchwork::wrap_plots(
  ggplot2::ggplot() +
    ggplot2::annotation_custom(p1A, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
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
#+ 6.2: Figure 2 
Figure_2 <- patchwork::wrap_plots(
  p2A + ggplot2::labs(tag = "A") + ggplot2::theme(plot.tag.position = c(0, 0.85), plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")), 
  p2B + ggplot2::labs(tag = "B") + ggplot2::theme(plot.tag.position = c(0, 0.85), plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")), 
  p2C + ggplot2::labs(tag = "C") + ggplot2::theme(plot.tag.position = c(0, 0.98), plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")), 
  p2D + ggplot2::labs(tag = "D") + ggplot2::theme(plot.tag.position = c(0, 0.98), plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")),
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
