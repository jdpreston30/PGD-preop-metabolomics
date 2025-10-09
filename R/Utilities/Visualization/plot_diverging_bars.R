#' Create Diverging Bar Plot for Fold Changes
#'
#' This function creates a horizontal diverging bar plot showing log2 fold changes
#' for significant metabolomic features, with styling consistent with volcano plots.
#'
#' @param results_tibble Tibble with columns: identified_name, fold_change
#' @param base_family Font family for plots (default: "Arial")
#' @param max_features Maximum number of features to display (default: 20)
#' @param order_by Column to order features by for selection (default: "p_value")
#' @param title Plot title (default: "Log2 Fold Change (Severe vs No Severe PGD)")
#' @param text_scale Scaling factor for all text elements (default: 1.0, use 0.8 for 80% size, etc.)
#'
#' @return ggplot object
#'
#' @examples
#' \dontrun{
#'   # Create diverging bar plot
#'   p <- plot_diverging_bars(
#'     results_tibble = inspect,
#'     max_features = 15
#'   )
#'   print(p)
#' }
#'
#' @export
plot_diverging_bars <- function(results_tibble,
                                base_family = "Arial",
                                max_features = 20,
                                order_by = "p_value",
                                text_scale = 1.0,
                                title = NULL) {
  
  # Load required libraries
  library(dplyr)
  library(ggplot2)
  library(stringr)
  
  # Prepare data
  plot_data <- results_tibble %>%
    # Use existing log2_FC/log2FC column if available, otherwise calculate from fold_change
    {
      if ("log2_fc" %in% names(.)) {
        # log2_fc already exists, use as-is
        .
      } else if ("log2FC" %in% names(.)) {
        # log2FC exists, rename to log2_fc
        rename(., log2_fc = log2FC)
      } else {
        # Neither exists, calculate from fold_change
        mutate(., log2_fc = log2(fold_change))
      }
    } %>%
    # Create color category based on fold change direction
    mutate(
      fc_direction = ifelse(log2_fc >= 0, "positive", "negative"),
      # Clean feature names for display and add +/- prefix
      display_name = str_replace_all(identified_name, "_", " "),
      display_name = str_wrap(display_name, width = 40),  # Increased width to reduce line breaks
      # Convert to absolute values for plotting (positive x-axis only)
      log2_fc_abs = abs(log2_fc)
    ) %>%
    # Take top features first (by order_by if specified, otherwise all)
    {if(order_by != "log2_fc") arrange(., !!sym(order_by)) else .} %>%
    slice_head(n = max_features) %>%
    # Simple ordering: highest log2FC to lowest log2FC (original values, not absolute)
    arrange(log2_fc) %>%
    mutate(
      display_name = factor(display_name, levels = display_name)  # Keep this exact order
    )
  
  # Color scheme: dark red for positive FC, dark blue for negative FC
  colors <- c(
    "positive" = "#800017",  # Dark red for positive fold changes
    "negative" = "#113d6a"   # Dark blue for negative fold changes
  )
  
  # Publication-style theme matching your existing plots
  theme_pub_diverging <- function() {
    theme_minimal(base_family = "Arial") +
      theme(
        # Panel styling - clean background with boxed border
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(),
        panel.border = element_rect(color = "black", fill = NA, linewidth = 1.15),
        
        # Axis styling - matching volcano plot exactly
        axis.ticks = element_line(color = "black", linewidth = 0.6),
        axis.ticks.length = unit(0.15, "cm"),
        axis.text.x = element_text(size = 11 * text_scale, face = "bold", color = "black"),
        axis.text.y = element_text(size = 5 * text_scale, face = "bold", color = "black", margin = margin(r = 2)),
        axis.title = element_text(size = 12 * text_scale, face = "bold", color = "black"),
        axis.title.x = element_text(size = 12 * text_scale, face = "bold", color = "black", margin = margin(t = 5)),
        axis.title.y = element_blank(),
        
        # Plot title
        plot.title = element_blank(),
        
        # Legend styling - small boxes centered at top
        legend.position = c(0.515, 1.025),
        legend.direction = "horizontal",
        legend.justification = "center",
        legend.title = element_blank(),
        legend.text = element_text(size = 5 * text_scale, face = "bold", color = "black", margin = margin(l = 2, r = 0)),
        legend.key.size = unit(0.35, "cm"),       # Much smaller boxes
        legend.key.width = unit(0.35, "cm"),     # Smaller width
        legend.key.height = unit(0.15, "cm"),    # Smaller height
        legend.margin = margin(b = -2),          # Less space below legend
        legend.box.margin = margin(b = -2),
        
        # Panel margins - give more space on the left for y-axis labels
        plot.margin = margin(t = 20, r = 10, b = 20, l = 10)
      )
  }
  
  # Create the plot
  p <- ggplot(plot_data, aes(x = log2_fc_abs, y = display_name, fill = fc_direction)) +
    # Add bars
    geom_col(width = 0.7, color = "black", linewidth = 0.3) +
    # Color and fill scales with descriptive labels
    scale_fill_manual(
      values = colors,
      labels = c("negative" = "Lower in Severe PGD", "positive" = "Higher in Severe PGD")
    ) +
    # Custom x-axis scale - force 0 to 5.2 with ticks at 0,1,2,3,4,5
    scale_x_continuous(
      limits = c(0, 5.3),
      breaks = c(0, 1, 2, 3, 4, 5),
      expand = c(0, 0)
    ) +
    # Axis labels
    labs(
      title = title,
      x = expression(bold("|log")[2]*bold("(Fold Change)|")),
      # y = "Metabolite"
    ) +
    # Apply theme
    theme_pub_diverging()
  
  return(p)
}
