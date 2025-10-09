#* 5: Plot Creation
#+ 5.1: Figure 1 Plots
p1A <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig1.png")), interpolate = TRUE)
#+ 5.2: Figure 2 Plots
{
  p2A <- plsda_allsev
  p2B <- volc_allsev
  p2C <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig2c.png")))
  p2D <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig2d.png")))
}
#+ 5.4: Figure 3 Plots
{
  # Diverging Bars
  p3A <- diverging_plot
  # Redox PPP Bars
  p3B.1 <- redox_ppp_plots[["6"]]
  p3B.2 <- redox_ppp_plots[["3"]]
  p3B.3 <- redox_ppp_plots[["9"]]
  p3B.4 <- redox_ppp_plots[["95"]]
  # Heme Antioxidant Bars
  p3C.1 <- heme_antioxidant_plots[["32"]]
  p3C.2 <- heme_antioxidant_plots[["45"]]
  # Lipid Remodeling
  p3D.1 <- lipid_remodel_plots[["5"]]
  p3D.2 <- lipid_remodel_plots[["68"]]
  p3D.3 <- lipid_remodel_plots[["121"]]
  p3D.4 <- lipid_remodel_plots[["134"]]
  # Amino Nitrogen
  p3E.1 <- amino_nitrogen_plots[["2"]]
  p3E.2 <- amino_nitrogen_plots[["42"]]
  p3E.3 <- amino_nitrogen_plots[["61"]]
  p3E.4 <- amino_nitrogen_plots[["157"]]
}
#+ 5.5: Supplemental Figures
#- 5.5.1: Supplemental Figure 1
S1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/S1.png")), interpolate = TRUE)
