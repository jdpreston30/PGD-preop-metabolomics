#* 5: Figure Creation
#!!!!!!!!!!! May need, not currently used
  # permanova_1B <- permanova_1B + theme_pub_simple(border_linewidth = 0.5)
  # pca_1C <- pca_1C + theme_pub_pca(border_linewidth = 0.5)
  # pca_1D <- pca_1D + theme_pub_pca(border_linewidth = 0.5)
  # pca_1E <- pca_1E + theme_pub_pca(border_linewidth = 0.5)
  # pca_1F <- pca_1F + theme_pub_pca(border_linewidth = 0.5)
#+ 5.0: Assign figures
#- 5.0.1: Figure 1 ----
fig1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig1.png")), interpolate = TRUE)
#- 5.0.2: Figure 2 ----
plsda_2A <- plsda_nosev
plsda_2B <- plsda_modsev
blank_2C <- volcano_nosev
blank_2D <- volcano_modsev
#- 5.0.3: Figure 3 ----
pathway_enrichment_3A <- pathway_enrichment
network_3B <- network_nosev
network_3C <- network_modsev
#- 5.0.4: Figure 4 ----
4A <- pls_bar_nosev
4B <- superclasses_nosev
4C <- classes_nosev
4D <- pls_bar_modsev
4E <- superclasses_modsev
4F <- classes_modsev
#+ 5.1: Figure 1----
Figure_1 <- patchwork::wrap_plots(
  # Top 50%: fig1 raster grob spanning full width
  ggplot2::ggplot() +
    ggplot2::annotation_custom(fig1, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = grid::unit(c(0, 0, 0, 0), "in")),
  # Bottom 50%: blank plot
  blank_plot,  
  design = "
    A
    B
  ",
  heights = c(1, 1) # 50% top, 50% bottom
) +
  patchwork::plot_annotation(
    title = "Figure 1",
    theme = ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
      plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
    )
  )

print_to_png(Figure_1, "Figure 1")


#+ 5.2: Figure 2 ----
Figure_2 <- patchwork::wrap_plots(
  # Top 40%: heatmap_2A spanning full width (100%)
  heatmap_2A,
  # Middle 20%: plsda_2B (left 50%) + plsda_2C (right 50%)
  plsda_2B, 
  plsda_2C,
  # Bottom 40% (placeholder for now)
  blank_2D,
  blank_2E,
  # # Bottom 40%: Volcano 2D (left) + Volcano 2E (right) #! not done yet, commented out for now
  # volcano_2D, volcano_2E,

  # Bottom 40%: Vertical PERMANOVA (left) + 4 PCAs (2x2 grid, right) #! might not need this
  # permanova_2B, pca_2C, pca_2D, pca_2E, pca_2F, #! might not need this
  
  design = "
    A
    CD
    EF
  ", # Top 40% heatmaps (A), Middle 20% PLSDAs (C,D), Bottom 40% blank plots (E,F)
  heights = c(2, 1, 2) # 40% top (2/5), 20% middle (1/5), 40% bottom (2/5)
) +
  patchwork::plot_annotation(
    title = "Figure 2",
    tag_levels = "A",
    theme = ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
      plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
    )
  ) &
  ggplot2::theme(
    plot.tag.position = c(0, 0.98),
    plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")
  )
print_to_png(Figure_2, "Figure 2")

#+ 5.3: Figure 3 - Pathway Enrichment-----
#- 5.3.1: Load in KEGG and enrichment plots

#- 5.3.2: Convert grob to ggplot for KEGG
kegg_as_plot <- ggplot2::ggplot() +
  ggplot2::annotation_custom(
    grid::rasterGrob(as.raster(magick::image_read("Outputs/Grob/variant_enrichment_plot_KEGG.png")),
      interpolate = TRUE
    ),
    xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf
  ) +
  ggplot2::theme_void() +
  ggplot2::theme(plot.margin = grid::unit(c(0, 0, 0, 0), "in"))
#- 5.3.4: Convert grob to ggplot for enrichment
enrichment_as_plot <- ggplot2::ggplot() +
  ggplot2::annotation_custom(
    grid::rasterGrob(as.raster(magick::image_read("Outputs/Grob/enrichment_network.png")),
      interpolate = TRUE
    ),
    xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf
  ) +
  ggplot2::theme_void() +
  theme(plot.margin = margin(t = -0, r = 0, b = 0, l = 0))
#- 5.3.3: Add the fixed title band via patchwork::plot_annotation
Figure_2 <- patchwork::wrap_plots(
  kegg_as_plot + ggplot2::labs(tag = "A"),
  enrichment_as_plot + ggplot2::labs(tag = "B"),
  blank_plot + ggplot2::labs(tag = NULL),
  blank_plot + ggplot2::labs(tag = NULL),
  design = "
      AB
      CD
      "
) +
  patchwork::plot_annotation(
    title = "Figure 2",
    theme = ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(
        hjust = 0, face = "bold", family = "Arial", size = 16
      ),
      plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in")
    )
  ) &
  ggplot2::theme(
    plot.tag = ggplot2::element_text(
      size = 14, face = "bold", family = "Arial", color = "black"
    ),
    plot.tag.position = c(0, 0.98)
  )
#- 5.3.4: Print
print_to_png(Figure_2, "Figure 2", dpi = 600)
#+ 5.4: Figure 4 - Targeted Metabolomics
#- 5.4.1 Assemble Figure 4
Figure_4 <- patchwork::wrap_plots(
  facet_4A, clusters_targ_4B, # Top 25%: A, B
  variant_targ_4C,
  design = "A\nB\nC",
  heights = c(0.25, 0.25, 0.25, 0.25)
) +
  patchwork::plot_annotation(
    title = "Figure 3",
    tag_levels = "A",
    theme = ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(
        hjust = 0, face = "bold", family = "Arial", size = 16
      ),
      plot.margin = grid::unit(c(0.3, 2, 0.3, 2), "in")
    )
  ) &
  ggplot2::theme(
    plot.tag.position = c(0, 0.98),
    plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")
  )
#- 5.3.2 Save Figure 3 to PNG
print_to_png(Figure_3, "Figure 3")
#+ 5.4: Supplemental Figure 1 - MFN Pathway Enrichment
#- 5.4.1: Load in MFN plot as grob
mfn_grob <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Grob/variant_enrichment_plot_MFN.png")), interpolate = TRUE)
#- 5.4.2: Convert grob to ggplot
mfn_as_plot <- ggplot2::ggplot() +
  ggplot2::annotation_custom(mfn_grob, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) +
  ggplot2::theme_void() +
  ggplot2::theme(plot.margin = grid::unit(c(0, 0, 0, 0), "in"))
#- 5.4.3: Add the fixed title band via patchwork::plot_annotation
Supplemental_Figure_1 <- mfn_as_plot +
  patchwork::plot_annotation(
    title = "Supplemental Figure 1",
    theme = ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(hjust = 0, face = "bold", family = "Arial", size = 16),
      plot.margin = grid::unit(c(0.3, 0.5, 0.3, 0.5), "in") # SAME as Fig 1 & 3
    )
  )
#- 5.4.4: Print
print_to_png(Supplemental_Figure_1, "Supplemental Figure 1")
#+ 5.5: Build combined PDF
{
  png_files <- c(
    here::here("Figures", "Figure 1.png"),
    here::here("Figures", "Figure 2.png")
    # here::here("Figures", "Figure 3.png"),
    # here::here("Figures", "Figure 4.png"),
    # here::here("Figures", "Supplemental Figure 1.png")
  )

  # Read them in
  imgs <- lapply(png_files, magick::image_read)

  # Combine into a single PDF
  pdf_file <- here::here("Figures", "Figures_Compiled.pdf")
  magick::image_write(magick::image_join(imgs), path = pdf_file, format = "pdf")

  message("✅ Combined PDF saved: ", pdf_file)
}