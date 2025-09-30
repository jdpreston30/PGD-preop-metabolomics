#* 6 Render Figures
#+ 6.1: Figure 1
Figure_1 <- patchwork::wrap_plots(
  ggplot() +
    annotation_custom(p1A, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    theme_void() +
    theme(plot.margin = grid::unit(c(0, 0, 0, 0), "in")),
  patchwork::plot_spacer(),  
  design = "
    A
    B
  ",
  heights = c(1, 1) # 50% top, 50% bottom
) +
  patchwork::plot_annotation(
    title = "Figure 1\n",
    theme = theme(
      plot.title.position = "plot",
      plot.title = element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
      plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
    )
  )
#+ 6.3: Figure 2 
Figure_2 <- patchwork::wrap_plots(
  #p2A
  p2A + 
  labs(tag = "A") + 
  theme(
    plot.tag.position = c(0.06, 0.9),
    plot.margin = grid::unit(c(0, 0, 0, 0.5), "in")  # right margin = 0
  ) +
  plot_tag_theme, 
  #p2B
  p2B + 
  labs(tag = "B") +
  theme(
    plot.tag.position = c(0.001, 0.9),
    plot.margin = grid::unit(c(0, 0.5, 0, 0), "in")  # left margin = 0
  ) +
  plot_tag_theme, 
  #p2C
  p2C + 
  labs(tag = "C") + 
  theme(
    plot.tag.position = c(0.06, 0.9),
    plot.margin = grid::unit(c(-10, 0, 0, 0.5), "in")  # right margin = 0
  ) +
  plot_tag_theme, 
  #p2D
  p2D + 
  labs(tag = "D") + 
  theme(
    plot.tag.position = c(0.001, 0.9),
    plot.margin = grid::unit(c(-10, 0.5, 0, 0), "in")  # left margin = 0
  ) +
  plot_tag_theme,
  #p2E
  p2E + 
  labs(tag = "E") + 
  theme(
    plot.tag.position = c(0.06, 0.9),
    plot.margin = grid::unit(c(-10, 0, 0, 0.5), "in")  # right margin = 0
  ) +
  plot_tag_theme,
  #p2F
  p2F + 
  labs(tag = "F") + 
  theme(
    plot.tag.position = c(0.001, 0.9),
    plot.margin = grid::unit(c(-10, 0.5, 0, 0), "in")  # left margin = 0
  ) +
  plot_tag_theme,
  patchwork::plot_spacer(), patchwork::plot_spacer(),
  design = "
      AB
      CD
      EF
      GH
  ", 
  heights = c(1, 1, 1, 1), # Three rows of plots, bottom fourth for spacers
  widths = c(1, 1.5)  # Overlapping columns to force compression
  ) +
    patchwork::plot_annotation(
      title = "Figure 2\n",
      theme = theme(
        plot.title.position = "plot",
        plot.title = element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
        plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
      )
    )
#+ Preview All
print_to_png(Figure_1, "fig1.png", width = 8.5, height = 11, dpi = 600)
print_to_png(Figure_2, "fig2.png", width = 8.5, height = 11, dpi = 600)
