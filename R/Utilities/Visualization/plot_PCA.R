#' Create PCA or PLS-DA plot from analysis results
#'
#' @param pca_results Results object from run_PCA function
#' @param plot_title Optional title for the plot (default: "")
#' @param ellipse_colors Named vector of colors for ellipses (light colors)
#' @param point_colors Named vector of colors for points (dark colors)
#' @param point_size Size of the points (default: 3 for standalone, 0.5 for multi-panel)
#' @param show_patient_labels Logical, whether to show Patient IDs as text labels (default: FALSE)
#' @param label_size Size of patient ID labels when show_patient_labels = TRUE (default: 3)
#' @param show_legend Logical, whether to show the legend (default: TRUE)
#' @return ggplot object
#' @export
plot_PCA <- function(pca_results, plot_title = "",
                     ellipse_colors = c("Severe PGD" = "#D8919A", "No PGD" = "#87A6C7", "Mild/Mod. PGD" = "#9CAF88"),
                     point_colors = c("Severe PGD" = "#800017", "No PGD" = "#113d6a", "Mild/Mod. PGD" = "#4A5D23"),
                     point_size = 2, show_patient_labels = FALSE, label_size = 3, show_legend = TRUE) {
  
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

  # _Create PCA plot
  pca_plot <- ggplot2::ggplot() +
    # Plot complete cases with colors and ellipses
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
    # Plot NA values as open circles without color
    {
      if (nrow(scores_df_na) > 0) {
        ggplot2::geom_point(
          data = scores_df_na,
          ggplot2::aes(x = Comp1, y = Comp2),
          size = point_size, shape = 1, color = "black", fill = NA
        )
      }
    } +
    # Add patient labels if requested
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
    # Set colors and styling
    ggplot2::scale_fill_manual(values = ellipse_colors, na.value = "grey50") +
    ggplot2::scale_color_manual(values = point_colors, na.value = "grey50") +
    ggplot2::labs(
      title = plot_title,
      x = paste0(comp_label, comp_x, " (", explained[1], "%)"),
      y = paste0(comp_label, comp_y, " (", explained[2], "%)")
    ) +
    # Force complete frame by duplicating axes
    ggplot2::scale_x_continuous(sec.axis = ggplot2::dup_axis(name = NULL, labels = NULL)) +
    ggplot2::scale_y_continuous(sec.axis = ggplot2::dup_axis(name = NULL, labels = NULL)) +
    ggplot2::theme_minimal(base_family = "Arial") +
    ggplot2::theme(
      # Square aspect ratio and margins (from your original)
      aspect.ratio = 1,
      plot.margin = grid::unit(c(2, 8, 8, 8), "pt"),
      
      # Legend styling - conditional based on show_legend parameter (your original style)
      legend.position = if (show_legend) "top" else "none",
      legend.direction = "horizontal",
      legend.box = "horizontal",
      legend.box.margin = ggplot2::margin(0, 0, 0, 0),
      legend.margin = ggplot2::margin(t = 0, r = 0, b = -10, l = 0),  # Increased negative bottom margin to pull legend closer
      legend.key.width = grid::unit(0.35, "cm"),
      legend.key.height = grid::unit(0.35, "cm"),
      legend.key.size = grid::unit(0.35, "cm"),
      legend.spacing.x = grid::unit(0, "cm"),
      legend.text.align = -10,
      legend.text = ggplot2::element_text(size = 7, face = "bold"),
      legend.title = ggplot2::element_blank(),
      
      # Axis styling (matching volcano plot exactly)
      axis.title = ggplot2::element_text(size = 12.5, face = "bold", color = "black"),
      axis.title.x = ggplot2::element_text(size = 12.5, face = "bold", color = "black", margin = ggplot2::margin(t = 2)),
      axis.title.y = ggplot2::element_text(size = 12.5, face = "bold", color = "black", margin = ggplot2::margin(r = 2), hjust = 0.5),
      axis.text = ggplot2::element_text(size = 11, face = "bold", color = "black"),
      
      # Panel styling - complete frame using axis lines (matches volcano exactly)
      panel.grid.major = ggplot2::element_line(color = "gray80", linewidth = 0.3, linetype = "solid"),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),  # Remove panel border
      panel.background = ggplot2::element_blank(),
      
      # Create complete frame using axis lines (all four sides)
      axis.line = ggplot2::element_line(color = "black", linewidth = 0.6),
      axis.line.x.bottom = ggplot2::element_line(color = "black", linewidth = 0.6),
      axis.line.x.top = ggplot2::element_line(color = "black", linewidth = 0.6),
      axis.line.y.left = ggplot2::element_line(color = "black", linewidth = 0.6),
      axis.line.y.right = ggplot2::element_line(color = "black", linewidth = 0.6),
      # Ticks only on bottom and left (primary axes)
      axis.ticks.x.bottom = ggplot2::element_line(color = "black", linewidth = 0.6),
      axis.ticks.y.left = ggplot2::element_line(color = "black", linewidth = 0.6),
      axis.ticks.length = ggplot2::unit(0.15, "cm"),
      # No ticks on top and right (secondary axes)
      axis.ticks.x.top = ggplot2::element_blank(),
      axis.ticks.y.right = ggplot2::element_blank(),
      
      # Title styling
      plot.title = ggplot2::element_text(size = 14, face = "bold", hjust = 0.5, color = "black")
    )
  
  return(pca_plot)
}