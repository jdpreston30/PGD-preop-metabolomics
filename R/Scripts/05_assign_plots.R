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
# p4B <- superclasses_nosev
# p4C <- classes_nosev
# p4D <- pls_bar_modsev
# p4E <- superclasses_modsev
# p4F <- classes_modsev
#+ 5.5: Supplemental Figures
#- 5.5.1: Supplemental Figure 1
S1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/S1.png")), interpolate = TRUE)
