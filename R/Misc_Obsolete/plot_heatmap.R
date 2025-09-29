#' Create heatmap plot from analysis results
#'
#' @param heatmap_results Results object from run_heatmap function
#' @param group_colors Named color vector for the grouping variable (names = levels)
#' @param color_palette Color palette for heatmap (default: RdBu)
#' @param show_rownames Logical, whether to show feature names (default: FALSE)
#' @param show_colnames Logical, whether to show sample names (default: FALSE)
#' @param fontsize Font size for the plot (default: 8)
#' @param legend_labels Label for the color legend (default: "Z-Score")
#' @param silent Logical, whether to suppress auto-display (default: TRUE for patchwork compatibility)
#' @return pheatmap object for use with patchwork
#' @export
plot_heatmap <- function(
    heatmap_results,
    group_colors = c("Severe PGD" = "#D8919A", "No PGD" = "#87A6C7", "Mild/Mod. PGD" = "#9CAF88"),
    color_palette = colorRampPalette(rev(RColorBrewer::brewer.pal(11, "RdBu")))(255),
    show_rownames = FALSE,
    show_colnames = FALSE,
    fontsize = 8,
    legend_labels = "Z-Score",
    silent = TRUE) {
  
  # Extract data from results
  M <- heatmap_results$M
  ann_col <- heatmap_results$ann_col
  group_var <- heatmap_results$group_var
  
  #  Annotation color lists 
  ann_colors <- list()
  ann_colors[[group_var]] <- group_colors

  # Create heatmap plot object for patchwork
  heatmap_plot <- pheatmap::pheatmap(
    M,
    scale = "row",
    color = color_palette,
    clustering_distance_rows = "euclidean",
    clustering_distance_cols = "euclidean",
    clustering_method = "complete",
    annotation_col = ann_col,
    annotation_colors = ann_colors,
    show_rownames = show_rownames,
    show_colnames = show_colnames,
    fontsize = fontsize,
    na_col = "#DDDDDD",
    silent = silent, # Prevents auto-display for patchwork compatibility
    legend_labels = legend_labels
  )

  return(heatmap_plot)
}