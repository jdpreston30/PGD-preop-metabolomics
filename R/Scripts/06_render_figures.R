
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
{
fig3 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
#- Plot positioning
# 3A
draw_plot(p3A, x = 0.65, y = 4.15, width = 3.7, height = 6) +
# 3B
draw_plot(p3B.1, x = 4.5, y = 8.215, width = 1.75, height = 1.75) +
draw_plot(p3B.2, x = 6.2, y = 8.215, width = 1.75, height = 1.75) +
draw_plot(p3B.3, x = 4.5, y = 6.5, width = 1.75, height = 1.75) +
draw_plot(p3B.4, x = 6.2, y = 6.5, width = 1.75, height = 1.75) +
# 3C
draw_plot(p3C.1, x = 4.5, y = 4.35, width = 1.75, height = 1.75) +
draw_plot(p3C.2, x = 6.2, y = 4.35, width = 1.75, height = 1.75) +
# 3D
draw_plot(p3D.1, x = 0.75, y = 2.2, width = 1.75, height = 1.75) +
draw_plot(p3D.2, x = 2.45, y = 2.2, width = 1.75, height = 1.75) +
draw_plot(p3D.3, x = 0.75, y = 0.485, width = 1.75, height = 1.75) +
draw_plot(p3D.4, x = 2.45, y = 0.485, width = 1.75, height = 1.75) +
# 3E
draw_plot(p3E.1, x = 4.5, y = 2.2, width = 1.75, height = 1.75) +
draw_plot(p3E.2, x = 6.2, y = 2.2, width = 1.75, height = 1.75) +
draw_plot(p3E.3, x = 4.5, y = 0.485, width = 1.75, height = 1.75) +
draw_plot(p3E.4, x = 6.2, y = 0.485, width = 1.75, height = 1.75) +
#- Labels
figure_labels(list(
  A = c(0.8, 10.15),
  B = c(4.5, 10.15), 
  C = c(4.5, 6.275),
  D = c(0.8, 4.135),
  E = c(4.5, 4.135),
  "Figure 3" = c(0.8, 10.7)
)) +
#- Panel group label
draw_label("Redox, PPP, Vitamin Cofactor Axis", 
           x = 6.405, y = 10.05, 
           hjust = 0.5, vjust = 0,
           size = 10, fontface = "bold") +
draw_label("Heme & Antioxidant Response", 
           x = 6.405, y = 6.175, 
           hjust = 0.5, vjust = 0,
           size = 10, fontface = "bold") +
draw_label("Lipid Remodeling & Injury Signaling", 
           x = 2.655, y = 4.035, 
           hjust = 0.5, vjust = 0,
           size = 10, fontface = "bold") +
draw_label("BCAA & Nitrogen Stress", 
           x = 6.405, y = 4.035, 
           hjust = 0.5, vjust = 0,
           size = 10, fontface = "bold")
# draw_line(x = c(2.655, 2.655), y = c(0, 11), color = "black", size = 0.5) +
# grid_guide(interval = 0.25, label_interval = 0.5)
}
#+ 6.4: Supplemental Figures
#- 6.4.1: Supplemental Figure 1
sup_fig1 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
  draw_plot(ggdraw() + draw_grob(S1), x = 1.655, y = 3.1, width = 3.46*1.5, height = 4.73*1.5) +
  figure_labels(list("Supplemental Figure 1" = c(0.8, 10.25)))
#+ 6.5: Preview All
print_to_png(fig1, "fig1.png", width = 8.5, height = 11, dpi = 1200)
print_to_png(fig2, "fig2.png", width = 8.5, height = 11, dpi = 1200)
print_to_png(fig3, "fig3.png", width = 8.5, height = 11, dpi = 1200)
print_to_png(sup_fig1, "S1.png", width = 8.5, height = 11, dpi = 1200)
