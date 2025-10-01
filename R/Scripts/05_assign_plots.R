#* 5: Plot Creation
#+ 5.1: Figure 1 Plots
p1A <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig1.png")), interpolate = TRUE)
#+ 5.2: Figure 2 Plots
p2A <- plsda_nosev 
p2B <- volc_nosev 
p2C <- plsda_modsev
p2D <- volc_modsev 
p2E <- plsda_allsev
p2F <- volc_allsev
#+ 5.3: Figure 3 Plots
p3A <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig3a.png")))
p3B <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig3b.png")))
p3C <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig3c.png")))
p3D <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/fig3d.png")))
#+ 5.4: Figure 4 Plots
# p4A <- pls_bar_nosev
# p4B <- superclasses_nosev
# p4C <- classes_nosev
# p4D <- pls_bar_modsev
# p4E <- superclasses_modsev
# p4F <- classes_modsev
#+ 5.5: Supplemental Figures
#- 5.5.1: Supplemental Figure 1
S1 <- grid::rasterGrob(as.raster(magick::image_read("Figures/Raw/S1.png")), interpolate = TRUE)
