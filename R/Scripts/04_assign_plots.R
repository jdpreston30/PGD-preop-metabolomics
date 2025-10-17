#* 4: Assign Plots
#+ 4.1: Figure 1 Plots
p1A <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/fig1.png")), interpolate = TRUE)
#+ 4.2: Figure 2 Plots
{
  p2A <- plsda_allsev
  p2B <- volc_allsev
  p2C <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/fig2c.png")))
  p2D <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/fig2d.png")))
}
#+ 4.3: Figure 3 Plots
{
  p3A <- diverging_plot
  p3B.1 <- nitrogen_plots[["1"]]
  p3B.2 <- nitrogen_plots[["11"]]
  p3B.3 <- nitrogen_plots[["12"]]
  p3B.4 <- nitrogen_plots[["15"]]
  p3B.5 <- nitrogen_plots[["59"]]
  p3B.6 <- nitrogen_plots[["65"]]
  # Lipid Remodeling
  p3C.1 <- lipid_plots[["3"]]
  p3C.2 <- lipid_plots[["44"]]
  p3C.3 <- lipid_plots[["47"]]
  p3C.4 <- lipid_plots[["62"]]
  # Amino Nitrogen
  p3D.1 <- redox_plots[["2"]]
  p3D.2 <- redox_plots[["4"]]
  p3D.3 <- redox_plots[["41"]]
  p3D.4 <- redox_plots[["70"]]
}
#+ 4.4: Supplemental Figures
#- 4.4.1: Supplemental Figure 1
S1 <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/S1.png")), interpolate = TRUE)
#- 4.4.2: Supplemental Figure 2
{
S2.1 <- S2$pages[[1]]
S2.2 <- S2$pages[[2]]
S2.3 <- S2$pages[[3]]
S2.4 <- S2$pages[[4]]
S2.5tf <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/S2.5tf.png")), interpolate = TRUE)
S2.5ta <- grid::rasterGrob(as.raster(magick::image_read("Outputs/Figures/Raw/S2.5ta.png")), interpolate = TRUE)
}
