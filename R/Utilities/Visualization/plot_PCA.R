plot_PCA <- function(pca_results, plot_title = "",
                     ellipse_colors = c("Severe PGD" = "#D8919A", "No Severe PGD" = "#87A6C7", "Mild/Mod. PGD" = "#FF9966", "No/Mild/Mod. PGD" = "#9CAF88"),
                     point_colors = c("Severe PGD" = "#800017", "No Severe PGD" = "#113d6a", "Mild/Mod. PGD" = "#be5010ff", "No/Mild/Mod. PGD" = "#4A5D23"),
                     point_size = 1.3, show_patient_labels = FALSE, label_size = 3,
                     x_limits = NULL, y_limits = NULL, x_expand = NULL, y_expand = NULL) {
  # Extract data from results
  scores_df <- pca_results$scores_df
  explained <- pca_results$explained_variance
  comp_x <- pca_results$comp_x
  comp_y <- pca_results$comp_y
  comp_label <- pca_results$comp_label

  # Identify NA values and create separate datasets
  na_mask <- is.na(scores_df$Class)
  scores_df_complete <- scores_df[!na_mask, , drop = FALSE]
  scores_df_na <- scores_df[na_mask, , drop = FALSE]

  # Create PCA plot
  pca_plot <- ggplot2::ggplot() +
    {
      if (nrow(scores_df_complete) > 0) {
        list(
          ggplot2::geom_point(
            data = scores_df_complete,
            ggplot2::aes(x = Comp1, y = Comp2, color = Class),
            size = point_size, shape = 16
          ),
          ggplot2::stat_ellipse(
            data = scores_df_complete,
            ggplot2::aes(x = Comp1, y = Comp2, fill = Class),
            geom = "polygon", alpha = 0.3, color = NA
          )
        )
      }
    } +
    {
      if (nrow(scores_df_na) > 0) {
        ggplot2::geom_point(
          data = scores_df_na,
          ggplot2::aes(x = Comp1, y = Comp2),
          size = point_size, shape = 1, color = "black", fill = NA
        )
      }
    } +
    {
      if (show_patient_labels) {
        list(
          if (nrow(scores_df_complete) > 0) {
            ggplot2::geom_text(
              data = scores_df_complete,
              ggplot2::aes(x = Comp1, y = Comp2, label = Patient),
              size = label_size, hjust = 0.5, vjust = -0.5, color = "black"
            )
          },
          if (nrow(scores_df_na) > 0) {
            ggplot2::geom_text(
              data = scores_df_na,
              ggplot2::aes(x = Comp1, y = Comp2, label = Patient),
              size = label_size, hjust = 0.5, vjust = -0.5, color = "black"
            )
          }
        )
      }
    } +
    ggplot2::scale_fill_manual(values = ellipse_colors, na.value = "grey50") +
    ggplot2::scale_color_manual(values = point_colors, na.value = "grey50") +
    ggplot2::guides(fill = ggplot2::guide_legend(), color = ggplot2::guide_legend()) +  # Remove reverse to get blue left, red right
    ggplot2::labs(
      title = plot_title,
      x = paste0(comp_label, comp_x, " (", explained[1], "%)"),
      y = paste0(comp_label, comp_y, " (", explained[2], "%)")
    ) +
    ggplot2::scale_x_continuous(
      limits = x_limits,
      sec.axis = ggplot2::dup_axis(name = NULL, labels = NULL),
      expand = ggplot2::expansion(mult = 0.05)
    ) +
    ggplot2::scale_y_continuous(
      limits = y_limits,
      sec.axis = ggplot2::dup_axis(name = NULL, labels = NULL),
      expand = ggplot2::expansion(mult = 0.05)
    ) +
    ggplot2::theme_minimal(base_family = "Arial") +
    ggplot2::theme(
      aspect.ratio = 1,
      plot.margin = grid::unit(c(0, 0, 0, 0), "pt"),
      legend.position = c(0.5, 1.07), 
      legend.justification = c(0.5, 0.5), 
      legend.direction = "horizontal",
      legend.text = ggplot2::element_text(size = 7, face = "bold", margin = ggplot2::margin(l = 1, r = 5)),
      legend.box.just = "center", 
      legend.key.width = grid::unit(0.35, "cm"),
      legend.key.height = grid::unit(0.35, "cm"),
      legend.key.size = grid::unit(0.35, "cm"),
      legend.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_line(color = "black", linewidth = 0.6),
      axis.ticks.x.top = ggplot2::element_blank(),
      axis.ticks.y.right = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(size = 11, face = "bold", color = "black"),
      axis.title.y = ggplot2::element_text(
        size = 12.5, face = "bold", color = "black",
        margin = ggplot2::margin(r = -5)  # nudges the label to the right
      ),
      axis.title.x = ggplot2::element_text(
        size = 12.5, face = "bold", color = "black",
        margin = ggplot2::margin(t = 5)  # nudges the label to the right
      ),
      panel.grid.major = ggplot2::element_line(color = "gray80", linewidth = 0.15, linetype = "solid"),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(color = "black", fill = NA, linewidth = 1.15),
      panel.background = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(size = 14, face = "bold", hjust = 0.5, color = "black")
    )
  
  if (!is.null(x_expand) && !is.null(y_expand)) {
    pca_plot <- pca_plot + ggplot2::expand_limits(x = x_expand, y = y_expand)
  } else if (!is.null(x_expand)) {
    pca_plot <- pca_plot + ggplot2::expand_limits(x = x_expand)
  } else if (!is.null(y_expand)) {
    pca_plot <- pca_plot + ggplot2::expand_limits(y = y_expand)
  }

  return(pca_plot)
}
