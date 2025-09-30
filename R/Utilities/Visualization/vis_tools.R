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
