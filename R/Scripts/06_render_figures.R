
#* 6 Render Figures
#+ 6.1: Figure 1
fig1 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
  draw_plot(ggdraw() + draw_grob(p1A), x = 0.1, y = 4.6, width = 8.5, height = 6) +
  figure_labels(list("Figure 1" = c(0.8, 10.25)))
#+ 6.2: Figure 2 (cowplot version with preserved aspect ratios)
fig2 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
#- Plot positioning
draw_plot(p2A, x = 0.9, y = 7.55, width = 2.5, height = 2.5) +
draw_plot(p2B, x = 3.7, y = 7.43, width = 4, height = 2.45) +
draw_plot(ggdraw() + draw_grob(p2C), x = .6, y = 4.05, width = 4.5/1.3, height = 4.28/1.3) +
draw_plot(ggdraw() + draw_grob(p2D), x = 4.0, y = 3.95, width = 10.5/3, height = 12/3) +
#- Labels
figure_labels(list(
  A = c(0.8, 10.15),
  B = c(3.7, 10.15), 
  C = c(0.8, 7.2),
  D = c(3.7, 7.2),
  "Figure 2" = c(0.8, 10.5)
))
#+ 6.3: Figure 3
fig3 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
#- Plot positioning
draw_plot(p3A, x = 0.9, y = 4.15, width = 3.25, height = 6) +
draw_plot(p3B.1, x = 4.4, y = 8.215, width = 1.75, height = 1.75) +
draw_plot(p3B.2, x = 6.2, y = 8.215, width = 1.75, height = 1.75) +
draw_plot(p3B.3, x = 4.4, y = 6.5, width = 1.75, height = 1.75) +
draw_plot(p3C.1, x = 4.4, y = 4.415, width = 1.75, height = 1.75) +
draw_plot(p3C.2, x = 6.2, y = 4.415, width = 1.75, height = 1.75) +
draw_plot(p3D.1, x = 0.8, y = 2.2, width = 1.75, height = 1.75) +
draw_plot(p3D.2, x = 2.6, y = 2.2, width = 1.75, height = 1.75) +
draw_plot(p3D.3, x = 0.8, y = 0.485, width = 1.75, height = 1.75) +
draw_plot(p3E, x = 4.4, y = 2.2, width = 1.75, height = 1.75) +
draw_plot(p3F, x = 6.2, y = 2.2, width = 1.75, height = 1.75) +
#- Labels
figure_labels(list(
  A = c(0.8, 10.15),
  B = c(4.4, 10.15), 
  C = c(4.4, 6.35),
  D = c(0.8, 4.135),
  E = c(4.4, 4.135),
  "Figure 3" = c(0.8, 10.7)
)) +
#- Panel group label
draw_label("BCAAs and Related Amino Acids", 
           x = 6.4, y = 10.05, 
           hjust = 0.5, vjust = 0,
           size = 10, fontface = "bold") +
draw_label("Tryptophan/Serotonin Axis", 
           x = 6.4, y = 6.25, 
           hjust = 0.5, vjust = 0,
           size = 10, fontface = "bold") +
draw_label("Energy/Sugars/Redox", 
           x = 2.675, y = 4.035, 
           hjust = 0.5, vjust = 0,
           size = 10, fontface = "bold") +
draw_label("Lipids and Drug Metabolites", 
           x = 6.4, y = 4.035, 
           hjust = 0.5, vjust = 0,
           size = 10, fontface = "bold") + 
draw_plot(AMINOPHENOL, x = 6.2, y = 6.5, width = 1.75, height = 1.75)

print_to_png(fig3, "fig3.png", width = 8.5, height = 11, dpi = 600)
#+ 6.4: Supplemental Figures
#- 6.4.1: Supplemental Figure 1
sup_fig1 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
  draw_plot(ggdraw() + draw_grob(S1), x = 1.655, y = 3.1, width = 3.46*1.5, height = 4.73*1.5) +
  figure_labels(list("Supplemental Figure 1" = c(0.8, 10.25)))
#+ 6.5: Preview All
print_to_png(fig1, "fig1.png", width = 8.5, height = 11, dpi = 600)
print_to_png(fig2, "fig2.png", width = 8.5, height = 11, dpi = 600)
print_to_png(fig3, "fig3.png", width = 8.5, height = 11, dpi = 600)
print_to_png(sup_fig1, "S1.png", width = 8.5, height = 11, dpi = 600)
