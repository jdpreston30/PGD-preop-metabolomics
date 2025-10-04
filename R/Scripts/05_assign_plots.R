#* 5: Plot Creation
#+ 5.1: Figure 1 Plots
p1A <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig1.png")), interpolate = TRUE)
#+ 5.2: Figure 2 Plots
p2A <- plsda_allsev
p2B <- volc_allsev
p2C <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig2c.png")))
p2D <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig2d.png")))
#+ 5.4: Figure 3 Plots
 p3A <- diverging_plot
p3B.1 <- significant_feature_plots[["α-Ketoisocaproate*"]]
p3B.2 <- significant_feature_plots[["N-Acetylleucine"]]
p3B.3 <- significant_feature_plots[["2-Aminobutanoate"]]
p3B.4 <- significant_feature_plots[["4-Hydroxy-4-methyl-2-oxoadipate"]]
p3C.1 <- significant_feature_plots[["5-Hydroxy-L-tryptophan"]]
p3C.2 <- significant_feature_plots[["5-Methoxytryptamine"]]
p3D.1 <- significant_feature_plots[["Ribose"]]
p3D.2 <- significant_feature_plots[["Glutamyl-5-Phosphate"]]
p3D.3 <- significant_feature_plots[["N-Acetylglucosamine"]]
p3E <- significant_feature_plots[["Linoleic Acid"]]
p3F <- significant_feature_plots[["Desglymidodrine"]]

#+ 5.5: Supplemental Figures
#- 5.5.1: Supplemental Figure 1
S1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/S1.png")), interpolate = TRUE)
