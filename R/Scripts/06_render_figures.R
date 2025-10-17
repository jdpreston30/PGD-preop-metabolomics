#* 6 Render Figures
#+ 6.1: Figure 1
fig1 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
  draw_plot(ggdraw() + draw_grob(p1A), x = -0.065, y = 4.83, width = 8.5, height = 6) +
  figure_labels(list("Figure 1" = c(0.49, 10.43)))
#+ 6.2: Figure 2
fig2 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
#- 2A
draw_plot(p2A, x = 0.93, y = 7.53, width = 2.5, height = 2.5) +
#- 2B
draw_plot(p2B, x = 3.73, y = 7.41, width = 4, height = 2.45) +
#- 2C
draw_plot(ggdraw() + draw_grob(p2C), x = .63, y = 4.03, width = 4.5/1.3, height = 4.28/1.3) +
#- 2D
draw_plot(ggdraw() + draw_grob(p2D), x = 4.03, y = 3.93, width = 10.5/3, height = 12/3) +
#- Labels
figure_labels(list(
  A = c(0.83, 10.13),
  B = c(3.73, 10.13), 
  C = c(0.83, 7.18),
  D = c(3.73, 7.18),
  "Figure 2" = c(0.49, 10.43)
))
#+ 6.3: Figure 3
fig3 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
#- 3A
draw_plot(p3A, x = 0.5475, y = 4.13, width = 3.7, height = 6) +
#- 3B
draw_plot(p3B.1, x = 4.3975, y = 8.195, width = 1.75, height = 1.75) +
draw_plot(p3B.2, x = 6.0975, y = 8.195, width = 1.75, height = 1.75) +
draw_plot(p3B.3, x = 4.3975, y = 6.48, width = 1.75, height = 1.75) +
draw_plot(p3B.4, x = 6.0975, y = 6.48, width = 1.75, height = 1.75) +
draw_plot(p3B.5, x = 4.3975, y = 4.765, width = 1.75, height = 1.75) +
draw_plot(p3B.6, x = 6.0975, y = 4.765, width = 1.75, height = 1.75) +
#- 3D
draw_plot(p3C.1, x = 0.6475, y = 2.18, width = 1.75, height = 1.75) +
draw_plot(p3C.2, x = 2.3475, y = 2.18, width = 1.75, height = 1.75) +
draw_plot(p3C.3, x = 0.6475, y = 0.465, width = 1.75, height = 1.75) +
draw_plot(p3C.4, x = 2.3475, y = 0.465, width = 1.75, height = 1.75) +
#- 3E
draw_plot(p3D.1, x = 4.3975, y = 2.18, width = 1.75, height = 1.75) +
draw_plot(p3D.2, x = 6.0975, y = 2.18, width = 1.75, height = 1.75) +
draw_plot(p3D.3, x = 4.3975, y = 0.465, width = 1.75, height = 1.75) +
draw_plot(p3D.4, x = 6.0975, y = 0.465, width = 1.75, height = 1.75) +
#- Panel Sublabels
draw_label("Amino Acid Metabolism",
  x = 6.3025, y = 10.03,
  hjust = 0.5, vjust = 0,
  size = 10, fontface = "bold"
) +
draw_label("Lipid Remodeling & Injury Signaling",
  x = 2.5525, y = 4.015,
  hjust = 0.5, vjust = 0,
  size = 10, fontface = "bold"
) +
draw_label("Redox Axis",
  x = 6.3025, y = 4.015,
  hjust = 0.5, vjust = 0,
  size = 10, fontface = "bold"
) +
#- Labels
figure_labels(list(
  A = c(0.6975, 10.13),
  B = c(4.3975, 10.13), 
  C = c(0.6975, 4.115),
  D = c(4.3975, 4.115),
  "Figure 3" = c(0.49, 10.43)
))
#+ 6.4: Supplemental Figure 1
sup_fig1 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
draw_plot(ggdraw() + draw_grob(S1), x = 1.6675, y = 3.39, width = 3.46*1.5, height = 4.73*1.5)
#+ 6.5: Supplemental Figure 2
#- 6.5.1: Pages 1-4
# First four pages already imported and complete
#- 6.5.2: Page 5
S2.5 <- ggdraw(xlim = c(0, 8.5), ylim = c(0, 11)) +
draw_plot(ggdraw() + draw_grob(S2.5ta), x = 0.75, y = 2.25, width = 7, height = 7.75) +
draw_label("Abbreviations and Adducts Table", x = 4.25, y = 10.1, hjust = 0.5, size = 14, fontface = "italic", fontfamily = "Arial") +
draw_plot(ggdraw() + draw_grob(S2.5tf), x = 0.75, y = 0.928, width = 7, height = 1.3) +
draw_label("Footnote Table", x = 4.25, y = 2.1, hjust = 0.5, size = 14, fontface = "italic", fontfamily = "Arial") 
#+ 6.7: Print All
print_to_png(fig1, "PNG/fig1.png", width = 8.5, height = 11, dpi = 600)
print_to_png(fig2, "PNG/fig2.png", width = 8.5, height = 11, dpi = 600)
print_to_png(fig3, "PNG/fig3.png", width = 8.5, height = 11, dpi = 600)
print_to_png(sup_fig1, 
             "S1.png", width = 8.5, height = 11, dpi = 600, output_dir = "Supporting Information/Components/Figures")
print_to_png(S2.1 + add_s2_footnote(c("*", "c", "i")), 
             "S2.1.png", width = 8.5, height = 11, dpi = 600, output_dir = "Supporting Information/Components/Figures")
print_to_png(S2.2 + add_s2_footnote(c("c", "i")), 
             "S2.2.png", width = 8.5, height = 11, dpi = 600, output_dir = "Supporting Information/Components/Figures")
print_to_png(S2.3 + add_s2_footnote(c("c", "i")), 
             "S2.3.png", width = 8.5, height = 11, dpi = 600, output_dir = "Supporting Information/Components/Figures")
print_to_png(S2.4 + add_s2_footnote(c("c", "i")), 
             "S2.4.png", width = 8.5, height = 11, dpi = 600, output_dir = "Supporting Information/Components/Figures")
print_to_png(S2.5 + add_s2_footnote(c("*", "c", "i5")), 
             "S2.5.png", width = 8.5, height = 11, dpi = 600, output_dir = "Supporting Information/Components/Figures")
#+ 6.6: Convert main figures to PDFs
fig1_img <- image_read("Outputs/Figures/Final/PNG/fig1.png")
image_write(fig1_img, "Outputs/Figures/Final/PDF/fig1.pdf", format = "pdf", density = 600)
fig2_img <- image_read("Outputs/Figures/Final/PNG/fig2.png")
image_write(fig2_img, "Outputs/Figures/Final/PDF/fig2.pdf", format = "pdf", density = 600)
fig3_img <- image_read("Outputs/Figures/Final/PNG/fig3.png")
image_write(fig3_img, "Outputs/Figures/Final/PDF/fig3.pdf", format = "pdf", density = 600)
