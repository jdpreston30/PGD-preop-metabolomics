#* 5: Assign Plots
#+ 5.1: Figure 1 Plots
p1A <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/fig1.png")), interpolate = TRUE)
#+ 5.2: Figure 2 Plots
{
  p2A <- plsda_allsev
  p2B <- volc_allsev
  p2C <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/fig2c.png")))
  p2D <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/fig2d.png")))
}
#+ 5.4: Figure 3 Plots
{
  p3A <- diverging_plot
  p3B.1 <- redox_cofactor_plots[["2"]]
  p3B.2 <- redox_cofactor_plots[["4"]]
  p3B.3 <- redox_cofactor_plots[["41"]]
  p3B.4 <- redox_cofactor_plots[["70"]]
  # Heme Antioxidant Bars
  p3C.1 <- heme_antioxidant_plots[["17"]]
  p3C.2 <- heme_antioxidant_plots[["48"]]
  # Lipid Remodeling
  p3D.1 <- lipid_remodeling_plots[["3"]]
  p3D.2 <- lipid_remodeling_plots[["44"]]
  p3D.3 <- lipid_remodeling_plots[["47"]]
  p3D.4 <- lipid_remodeling_plots[["59"]]
  # Amino Nitrogen
  p3E.1 <- amino_nitrogen_plots[["1"]]
  p3E.2 <- amino_nitrogen_plots[["15"]]
  p3E.3 <- amino_nitrogen_plots[["42"]]
  p3E.4 <- amino_nitrogen_plots[["68"]]
}
#+ 5.5: Supplemental Figures
#- 5.5.1: Supplemental Figure 1
S1 <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/S1.png")), interpolate = TRUE)
#- 5.5.1: Supplemental Figure 2
{
S2.1 <- S2$pages[[1]]
S2.2 <- S2$pages[[2]]
S2.3 <- S2$pages[[3]]
S2.4 <- S2$pages[[4]]
S2.5tf <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/S2.5tf.png")), interpolate = TRUE)
S2.5ta <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/S2.5ta.png")), interpolate = TRUE)
}
