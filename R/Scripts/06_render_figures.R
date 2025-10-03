
#* 6 Render Figures
#+ 6.1: Figure 1
fig1 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
  draw_plot(ggdraw() + draw_grob(p1A), x = 0.1, y = 4.6, width = 8.5, height = 6) +
  figure_labels(list("Figure 1" = c(0.8, 10.25)))
#+ 6.3: Figure 2 (cowplot version with preserved aspect ratios)
fig2 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
#- Plot positioning
draw_plot(p2A, x = 0.9, y = 7.1, width = 2.5, height = 2.5) +
draw_plot(p2B, x = 3.7, y = 6.98, width = 4, height = 2.45) +
draw_plot(ggdraw() + draw_grob(p2C), x = .6, y = 3.6, width = 4.5/1.3, height = 4.28/1.3) +
draw_plot(ggdraw() + draw_grob(p2D), x = 4.0, y = 3.5, width = 10.5/3, height = 12/3) +
#- Labels
figure_labels(list(
  A = c(0.8, 9.7),
  B = c(3.7, 9.7), 
  C = c(0.8, 6.75),
  D = c(3.7, 6.75),
  "Figure 2" = c(0.8, 10.25)
))
#+ 6.4: Figure 3
fig3 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
#- Plot positioning
draw_plot(p3A, x = 0.9, y = 3.7, width = 4, height = 6) +
# draw_plot(p3B, x = 3.7, y = 6.98, width = 4, height = 2.45) +
#- Labels
figure_labels(list(
  A = c(0.8, 9.7),
  B = c(5.1, 9.7), 
  # C = c(0.8, 6.75),
  # D = c(3.7, 6.75),
  "Figure 3" = c(0.8, 10.25)
))
print_to_png(fig3, "fig3.png", width = 8.5, height = 11, dpi = 100)
#+ 6.5: Supplemental Figures
#- 6.5.1: Supplemental Figure 1
sup_fig1 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
  draw_plot(ggdraw() + draw_grob(S1), x = 1.655, y = 3.1, width = 3.46*1.5, height = 4.73*1.5) +
  figure_labels(list("Supplemental Figure 1" = c(0.8, 10.25)))
#+ 6.6: Preview All
print_to_png(fig1, "fig1.png", width = 8.5, height = 11, dpi = 600)
print_to_png(fig2, "fig2.png", width = 8.5, height = 11, dpi = 600)
print_to_png(fig3, "fig3.png", width = 8.5, height = 11, dpi = 600)
print_to_png(sup_fig1, "S1.png", width = 8.5, height = 11, dpi = 600)
