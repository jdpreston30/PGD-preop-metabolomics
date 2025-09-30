#* 6 Render Figures
#+ 6.1: Figure 1
Figure_1 <- patchwork::wrap_plots(
  ggplot2::ggplot() +
    ggplot2::annotation_custom(p1A, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = grid::unit(c(0, 0, 0, 0), "in")),
  patchwork::plot_spacer(),  
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
  #p2A
  p2A + 
  ggplot2::labs(tag = "A") + 
  ggplot2::theme(
    plot.tag.position = c(0.06, 0.9), 
    plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black"),
    plot.margin = grid::unit(c(0, 0, 0, 0.5), "in")  # right margin = 0
  ), 
  #p2B
  p2B + 
  ggplot2::labs(tag = "B") +
  ggplot2::theme(
    plot.tag.position = c(0.001, 0.9), 
    plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black"),
    plot.margin = grid::unit(c(0, 0.5, 0, 0), "in")  # left margin = 0
  ), 
  #p2C
  p2C + 
  ggplot2::labs(tag = "C") + 
  ggplot2::theme(
    plot.tag.position = c(0.06, 0.9), 
    plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black"),
    plot.margin = grid::unit(c(-10, 0, 0, 0.5), "in")  # right margin = 0
  ), 
  #p2D
  p2D + 
  ggplot2::labs(tag = "D") + 
  ggplot2::theme(
    plot.tag.position = c(0.001, 0.9), 
    plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black"),
    plot.margin = grid::unit(c(-10, 0.5, 0, 0), "in")  # left margin = 0
  ),
  patchwork::plot_spacer(), patchwork::plot_spacer(),
  design = "
      AB
      CD
      EF
  ", 
  heights = c(1, 1, 2.2), # Top plots (rows 1-4) = 50%, spacers (rows 5-6) = 50%
  widths = c(1, 1.5)  # Overlapping columns to force compression
  ) +
    patchwork::plot_annotation(
      title = "Figure 2\n",
      theme = ggplot2::theme(
        plot.title.position = "plot",
        plot.title = ggplot2::element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
        plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
      )
    )
#+ Preview All
print_to_png(Figure_1, "fig1.png", width = 8.5, height = 11, dpi = 600)
print_to_png(Figure_2, "fig2.png", width = 8.5, height = 11, dpi = 600)
