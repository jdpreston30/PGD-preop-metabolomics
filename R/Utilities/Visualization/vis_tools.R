blank_plot <- ggplot2::ggplot() +
  ggplot2::theme_void() +
  ggplot2::labs(tag = NULL) + # this removes the letter completely
  ggplot2::theme(
    plot.tag = ggplot2::element_text(color = "white")
  )
