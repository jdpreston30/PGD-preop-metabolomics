#+ Blank Plot for Spacing
blank_plot <- ggplot2::ggplot() +
  ggplot2::theme_void() +
  ggplot2::labs(tag = NULL) + # this removes the letter completely
  ggplot2::theme(
    plot.tag = ggplot2::element_text(color = "white")
  )

#+ Plot Tag Theme
plot_tag_theme <- ggplot2::theme(
  plot.tag = ggplot2::element_text(size = 14, face = "bold", vjust = 0, hjust = 0, family = "Arial", color = "black")
)

#+ Grid Guide for Positioning (cowplot coordinates)
grid_guide <- function(x_max = 8.5, y_max = 11, interval = 0.5, label_interval = 1) {
  list(
    ggplot2::geom_vline(xintercept = seq(0, x_max, interval), color = "red", alpha = 0.3, linetype = "dashed"),
    ggplot2::geom_hline(yintercept = seq(0, y_max, interval), color = "red", alpha = 0.3, linetype = "dashed"),
    ggplot2::annotate("text", x = seq(0, x_max, label_interval), y = 0.2, label = seq(0, x_max, label_interval), size = 3, color = "red"),
    ggplot2::annotate("text", x = 0.2, y = seq(0, y_max, label_interval), label = seq(0, y_max, label_interval), size = 3, color = "red")
  )
}

#+ Figure Labels Generator
figure_labels <- function(labels, size = 14, fontface = "bold", fontfamily = "Arial", hjust = 0) {
  # Convert single label to list format if needed
  if (is.character(labels)) {
    stop("Please provide labels as a named list with x and y coordinates, e.g., list(A = c(0.8, 9.7), B = c(3.7, 9.7))")
  }
  
  # Generate draw_label calls for each label
  label_layers <- list()
  for (name in names(labels)) {
    coords <- labels[[name]]
    label_layers[[length(label_layers) + 1]] <- 
      cowplot::draw_label(name, x = coords[1], y = coords[2], 
                         size = size, fontface = fontface, 
                         fontfamily = fontfamily, hjust = hjust)
  }
  
  return(label_layers)
}