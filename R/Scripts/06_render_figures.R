
#* 6 Render Figures
#+ 6.1: Figure 1
Figure_1 <- patchwork::wrap_plots(
  ggplot() +
    annotation_custom(p1A, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    theme_void() +
    theme(plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")),
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
    plot.margin = grid::unit(c(0, 0, 0, 0.5), "in")
  ) +
  plot_tag_theme, 
  #p2B
  p2B + 
  labs(tag = "B") +
  theme(
    plot.tag.position = c(0.001, 0.9),
    plot.margin = grid::unit(c(0, 0.5, 0, 0), "in")
  ) +
  plot_tag_theme,
  #p2C (raster grob - wrap in ggplot)
  ggplot() +
    annotation_custom(p2C, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    theme_void() +
    labs(tag = "C") +
    theme(
      plot.tag.position = c(0.06, 0.9),
      plot.margin = grid::unit(c(0.5, 0, 0, 0), "in")
    ) +
    plot_tag_theme,
  #p2D (raster grob - wrap in ggplot)
  ggplot() +
    annotation_custom(p2D, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    theme_void() +
    labs(tag = "D") +
    theme(
      plot.tag.position = c(0.001, 0.9),
      plot.margin = grid::unit(c(0.5, 0, 0, 0), "in")
    ) +
    plot_tag_theme,
  patchwork::plot_spacer(), patchwork::plot_spacer(),
  design = "
      AAAAABBBBB
      CCCCCDDDDD
      EEEEEFFFFF
      EEEEEFFFFF
  ", 
  heights = c(1, 1, 1, 1), # Four equal rows: A/B, C/D row 1, C/D row 2, spacer
  widths = c(0.5, 0.5)  # 30% for C, 70% for D
  ) +
    patchwork::plot_annotation(
      title = "Figure 2\n",
      theme = theme(
        plot.title.position = "plot",
        plot.title = element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
        plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
      )
    )
print_to_png(Figure_2, "fig2.png", width = 8.5, height = 11, dpi = 600)
#+ 6.3: Figure 3 (with separate label positioning)
Figure_3 <- cowplot::ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +  # Set to inches like page size
  cowplot::draw_plot(
    cowplot::ggdraw() + cowplot::draw_grob(p3A),
    x = 2.5, y = 8.1, scale = 4.25
  ) +
  cowplot::draw_plot(
    cowplot::ggdraw() + cowplot::draw_grob(p3B),
    x = 5.75, y = 8.11, scale = 3.0
  ) +
  cowplot::draw_plot(
    cowplot::ggdraw() + cowplot::draw_grob(p3C),
    x = 1.91, y = 4.697, scale = 3.0
  ) +
  cowplot::draw_plot(
    cowplot::ggdraw() + cowplot::draw_grob(p3D),
    x = 5.75, y = 4.697, scale = 3.0
  ) +
  cowplot::draw_label("A", x = 1.16, y = 10.053, hjust = 0, vjust = 1, size = 14, fontface = "bold", fontfamily = "Arial") +
  cowplot::draw_label("B", x = 5, y = 10.053, hjust = 0, vjust = 1, size = 14, fontface = "bold", fontfamily = "Arial") +
  cowplot::draw_label("C", x = 1.16, y = 6.7, hjust = 0, vjust = 1, size = 14, fontface = "bold", fontfamily = "Arial") +
  cowplot::draw_label("D", x = 5, y = 6.7, hjust = 0, vjust = 1, size = 14, fontface = "bold", fontfamily = "Arial") +
  cowplot::draw_label("Figure 3", x = 1, y = 10.7, hjust = 0, vjust = 1, size = 16, fontface = "bold", fontfamily = "Arial")
#+ 6.4: Figure 4
#+ 6.5: Supplemental Figures
#- 6.5.1: Supplemental Figure 1
Suppl_figure_1 <- patchwork::wrap_plots(
  ggplot() +
    annotation_custom(S1, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    theme_void() +
    theme(plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")),
  patchwork::plot_spacer(),
  design = "
    A
    B
  ",
  heights = c(0.6, 0.4)  # 60% picture, 40% spacer
) +
  patchwork::plot_annotation(
    title = "Supplemental Figure 1\n",
    theme = theme(
      plot.title.position = "plot",
      plot.title = element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
      plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
    )
  )
#+ 6.6: Preview All
print_to_png(Figure_1, "fig1.png", width = 8.5, height = 11, dpi = 600)
print_to_png(Figure_2, "fig2.png", width = 8.5, height = 11, dpi = 600)
print_to_png(Figure_3, "fig3.png", width = 8.5, height = 11, dpi = 600)
print_to_png(Suppl_figure_1, "S1.png", width = 8.5, height = 11, dpi = 600)
