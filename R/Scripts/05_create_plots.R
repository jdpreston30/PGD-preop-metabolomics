#* 5: Plot Creation
#+ 5.1: Create Fig. 1 Plots
fig1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig1.png")), interpolate = TRUE)
#+ 5.2: Create Fig. 2 Plots
#- 5.2.1: For No PGD vs Severe PLSDA
plsda_nosev <- plot_PCA(
  pca_results = plsda_nosev_data
)
#- 5.2.2: For Moderate vs Severe PLSDA
plsda_modsev <- plot_PCA(
  pca_results = plsda_modsev_data
)
#- 5.2.3: For No PGD vs Severe Volcano
volc_nosev <- plot_volcano(
  volcano_results = volcano_nosev_data,
  x_limits = c(-6, 6.435),
  y_limits = c(0, 6.1),
)
#- 5.2.4: For Moderate vs Severe Volcano
volc_modsev <- plot_volcano(
  volcano_results = volcano_modsev_data,
  x_limits = c(-6, 6.435),
  y_limits = c(0, 6.1),
  down_color = "#be5010ff"  
)
#- 5.2.5: For No+Mild/Mod. PGD vs Severe PLSDA
plsda_allsev <- plot_PCA(
  pca_results = plsda_allsev_data
)
#- 5.2.6: For No+Mild/Mod. PGD vs Severe Volcano
volc_allsev <- plot_volcano(
  volcano_results = volcano_allsev_data,
  x_limits = c(-6, 6.435),
  y_limits = c(0, 6.1),
  down_color = "#4A5D23"
)
#+ 5.3: Figure 3 Plots
#- 5.3.1: Create MFN enrichment plot
pgd_enrichment_plot_mfn <- plot_pathway_enrichment(
  nosev_pathways = mfn_nosev_pathways,
  modsev_pathways = mfn_modsev_pathways,
  allsev_pathways = mfn_allsev_pathways,
  p_method = "fisher",
  enrichment_cap = 5,
  size_range = c(5, 11),
  size_breaks = c(5, 3, 1),
  show_legend = TRUE,
  save_path = "Figures/Raw/fig2a.png",
  plot_width = 7.5,
  plot_height = 7.5,
  dpi = 600
)
#- 5.3.2: Bring in hard copy of enrichment plot
fig1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig2a.png")), interpolate = TRUE)
#+ 5.6: Assign plots for figure assembly
#- 5.2.1: Figure 1
p1A <- fig1
#- 5.2.2: Figure 2
p2A <- plsda_nosev 
p2B <- volc_nosev 
p2C <- plsda_modsev
p2D <- volc_modsev 
p2E <- plsda_allsev
p2F <- volc_allsev
#- 5.2.3: Figure 3
p3A <- pgd_enrichment_plot_mfn
p3B <- network_nosev
p3C <- network_modsev
p3D <- network_allsev
#- 5.2.4: Figure 4 
# p4A <- pls_bar_nosev
# p4B <- superclasses_nosev
# p4C <- classes_nosev
# p4D <- pls_bar_modsev
# p4E <- superclasses_modsev
# p4F <- classes_modsev
#+ Supplemental Figures
pgd_enrichment_plot_combined <- plot_pathway_enrichment(
  nosev_pathways = mfn_nosev_pathways,
  modsev_pathways = mfn_modsev_pathways,
  allsev_pathways = mfn_allsev_pathways,
  p_method = "combined",
  nosev_pathways_kegg = kegg_nosev_pathways,
  modsev_pathways_kegg = kegg_modsev_pathways,
  allsev_pathways_kegg = kegg_allsev_pathways,
  enrichment_cap = 7,
  size_range = c(5, 11),
  size_breaks = c(7, 5, 3, 1),
  show_legend = TRUE,
  save_path = "Outputs/Grob/pgd_enrichment_plot_combined.png",
  plot_width = 8.1,
  plot_height = 11.575,
  dpi = 600
)
#+ 5.7: Assign Supplementary Figures For Assembly
#- 5.3.1: Supplementary Figure 1
sup1A <- pgd_enrichment_plot_combined