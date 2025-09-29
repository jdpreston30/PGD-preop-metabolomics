#' Create volcano plot with automatic t-tests on feature table
#'
#' @param data Data frame with patient IDs, grouping variable, and feature columns
#' @param group_var Character string specifying the column name to use for grouping
#' @param patient_var Character string specifying the Patient ID column name (default: "Patient")
#' @param group_levels Optional vector specifying factor levels for grouping (must be exactly 2 levels)
#' @param fc_threshold Fold change threshold for significance (default: log2(1.5) = 0.585)
#' @param p_threshold P-value threshold for significance (default: 0.05)
#' @param up_color Color for upregulated features (default: "#800017")
#' @param down_color Color for downregulated features (default: "#113d6a")
#' @param x_limits Optional vector of length 2 specifying x-axis limits c(min, max). If NULL, auto-scales.
#' @param y_limits Optional vector of length 2 specifying y-axis limits c(min, max). If NULL, auto-scales.
#' @return List containing volcano_data and volcano_plot
#' @import ggplot2 scales
#' @export
make_volcano <- function(data, 
                        group_var, 
                        patient_var = "Patient",
                        group_levels = NULL,
                        fc_threshold = log2(1.5),
                        p_threshold = 0.05,
                        up_color = "#800017",
                        down_color = "#113d6a",
                        x_limits = NULL,
                        y_limits = NULL) {
  
  #  Data preparation 
  if (!group_var %in% names(data)) {
    stop(paste("Group variable", group_var, "not found in data"))
  }
  if (!patient_var %in% names(data)) {
    stop(paste("Patient variable", patient_var, "not found in data"))
  }
  
  dat <- as.data.frame(data)
  
  # Set up grouping variable
  if (!is.null(group_levels)) {
    dat[[group_var]] <- factor(dat[[group_var]], levels = group_levels)
  } else {
    dat[[group_var]] <- factor(dat[[group_var]])
  }
  
  # Check for exactly 2 groups
  n_groups <- length(levels(dat[[group_var]]))
  if (n_groups != 2) {
    stop(paste("Volcano plot requires exactly 2 groups, but found", n_groups, "groups"))
  }
  
  # Identify numeric columns (exclude patient and grouping variables)
  factor_cols <- sapply(dat, is.factor)
  cols_to_exclude <- c(patient_var, group_var)
  other_factor_cols <- names(factor_cols)[factor_cols & !names(factor_cols) %in% cols_to_exclude]
  drop_cols <- c(cols_to_exclude, other_factor_cols)
  numeric_cols <- !names(dat) %in% drop_cols
  
  if (sum(numeric_cols) == 0) {
    stop("No numeric columns found for t-tests")
  }
  
  feature_data <- dat[, numeric_cols, drop = FALSE]
  group <- dat[[group_var]]
  
  message("Performing t-tests on ", ncol(feature_data), " features between ", 
          paste(levels(group), collapse = " vs "))
  
  #  Perform t-tests 
  ttest_results <- data.frame(
    feature = colnames(feature_data),
    p_value = NA,
    log2_fc = NA,
    mean_group1 = NA,
    mean_group2 = NA,
    stringsAsFactors = FALSE
  )
  
  group_names <- levels(group)
  
  for (i in seq_len(ncol(feature_data))) {
    feature_values <- feature_data[, i]
    
    # Skip if all values are identical
    if (length(unique(feature_values)) == 1) {
      next
    }
    
    # Calculate group means (log2 scale)
    group1_vals <- feature_values[group == group_names[1]]
    group2_vals <- feature_values[group == group_names[2]]
    
    mean1 <- mean(group1_vals, na.rm = TRUE)
    mean2 <- mean(group2_vals, na.rm = TRUE)
    
    # Calculate log2 fold change (group2 vs group1)
    log2_fc <- mean2 - mean1
    
    # Perform t-test
    tryCatch({
      t_result <- t.test(feature_values ~ group)
      ttest_results$p_value[i] <- t_result$p.value
      ttest_results$log2_fc[i] <- log2_fc
      ttest_results$mean_group1[i] <- mean1
      ttest_results$mean_group2[i] <- mean2
    }, error = function(e) {
      # Skip features that cause t-test errors
    })
  }
  
  # Remove failed tests
  ttest_results <- ttest_results[!is.na(ttest_results$p_value), ]
  
  #  Create volcano data 
  volcano_data <- ttest_results
  volcano_data$neg_log10_p <- -log10(volcano_data$p_value)
  
  # Classify significance with custom legend text
  volcano_data$Legend <- "Not Significant"
  
  # Determine legend labels based on comparison type
  if ("Mild/Moderate PGD" %in% group_names && "Severe PGD" %in% group_names) {
    # Mild/Moderate PGD vs Severe PGD comparison: both are "Up in" labels
    up_label <- "Up in Severe PGD"
    down_label <- "Up in Mild/Moderate PGD"
  } else {
    # Other comparisons (e.g., No PGD vs Severe): traditional up/down
    up_label <- "Up in Severe PGD"
    down_label <- "Down in Severe PGD"
  }
  
  volcano_data$Legend[volcano_data$p_value < p_threshold & volcano_data$log2_fc > fc_threshold] <- up_label
  volcano_data$Legend[volcano_data$p_value < p_threshold & volcano_data$log2_fc < -fc_threshold] <- down_label
  
  volcano_data$Legend <- factor(volcano_data$Legend, 
                               levels = c("Not Significant", up_label, down_label))
  
  #  Handle axis limits and warnings 
  # X-axis limits
  if (!is.null(x_limits)) {
    if (length(x_limits) != 2) {
      stop("x_limits must be a vector of length 2: c(min, max)")
    }
    x_range <- x_limits
    # Check for data outside x-axis range
    x_outside <- volcano_data$log2_fc < x_limits[1] | volcano_data$log2_fc > x_limits[2]
    if (any(x_outside, na.rm = TRUE)) {
      n_outside <- sum(x_outside, na.rm = TRUE)
      warning(paste(n_outside, "data points fall outside specified x-axis range",
                    paste0("(", x_limits[1], ", ", x_limits[2], ")")))
    }
  } else {
    # Auto-scale x-axis
    x_range <- c(-max(abs(volcano_data$log2_fc), na.rm = TRUE) * 1.1, 
                 max(abs(volcano_data$log2_fc), na.rm = TRUE) * 1.1)
  }
  
  # Y-axis limits  
  if (!is.null(y_limits)) {
    if (length(y_limits) != 2) {
      stop("y_limits must be a vector of length 2: c(min, max)")
    }
    y_range <- y_limits
    # Check for data outside y-axis range
    y_outside <- volcano_data$neg_log10_p < y_limits[1] | volcano_data$neg_log10_p > y_limits[2]
    if (any(y_outside, na.rm = TRUE)) {
      n_outside <- sum(y_outside, na.rm = TRUE)
      warning(paste(n_outside, "data points fall outside specified y-axis range",
                    paste0("(", y_limits[1], ", ", y_limits[2], ")")))
    }
  } else {
    # Auto-scale y-axis
    y_range <- c(-0.25, max(volcano_data$neg_log10_p, na.rm = TRUE) * 1.1)
  }
  
  #  Create plot 
  volcano_plot <- ggplot2::ggplot(
    volcano_data,
    ggplot2::aes(x = log2_fc, y = neg_log10_p, color = Legend)
  ) +
    ggplot2::geom_point(size = 0.5, na.rm = TRUE) +
    ggplot2::scale_color_manual(
      values = setNames(c("gray70", up_color, down_color), 
                       c("Not Significant", up_label, down_label)),
      name = NULL
    ) +
    ggplot2::theme_minimal(base_family = "Arial") +
    ggplot2::labs(
      x = expression(bold("log")[2]*bold("(Fold Change)")),
      y = expression(bold("-log")[10]*bold("(p)"))
    ) +
    ggplot2::theme(
      axis.title.x = ggplot2::element_text(size = 12.5, face = "bold", color = "black"),
      axis.title.y = ggplot2::element_text(size = 12.5, face = "bold", color = "black")
    ) +
    ggplot2::geom_hline(yintercept = -log10(p_threshold), linetype = "dashed", color = "black") +
    ggplot2::geom_vline(xintercept = c(-fc_threshold, fc_threshold), linetype = "dashed", color = "black") +
    ggplot2::scale_x_continuous(
      limits = x_range,
      breaks = function(x) {
        range_val <- diff(range(x))
        if (range_val <= 2) seq(ceiling(x[1]), floor(x[2]), 0.5)
        else if (range_val <= 6) seq(ceiling(x[1]), floor(x[2]), 1)
        else seq(ceiling(x[1]), floor(x[2]), 2)
      },
      minor_breaks = function(x) {
        range_val <- diff(range(x))
        if (range_val <= 2) seq(ceiling(x[1]), floor(x[2]), 0.25)
        else if (range_val <= 6) seq(ceiling(x[1]), floor(x[2]), 0.5)
        else seq(ceiling(x[1]), floor(x[2]), 1)
      },
      expand = c(0.02, 0)
    ) +
    ggplot2::scale_y_continuous(
      limits = y_range,
      breaks = function(x) {
        range_val <- diff(range(x))
        if (range_val <= 3) seq(0, ceiling(x[2]), 0.5)
        else if (range_val <= 6) seq(0, ceiling(x[2]), 1)
        else seq(0, ceiling(x[2]), 2)
      },
      minor_breaks = function(x) {
        range_val <- diff(range(x))
        if (range_val <= 3) seq(0, ceiling(x[2]), 0.25)
        else if (range_val <= 6) seq(0, ceiling(x[2]), 0.5)
        else seq(0, ceiling(x[2]), 1)
      },
      expand = c(0.02, 0)
    ) +
    ggplot2::theme(
      # Remove aspect ratio - let user control via export
      plot.margin = grid::unit(c(2, 8, 8, 8), "pt"),
      
      # Legend styling - top left corner (using robust approach for all ggplot2 versions)
      legend.position = c(0.02, 0.98),  # Position inside plot area
      legend.justification = c(0, 1),   # Anchor at top left of legend box
      legend.direction = "vertical",
      legend.box = "vertical", 
      legend.background = ggplot2::element_blank(),  # Remove box around legend
      legend.box.background = ggplot2::element_blank(),  # Also remove box background
      legend.box.margin = ggplot2::margin(0, 0, 0, 0),
      legend.margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0),
      legend.key = ggplot2::element_blank(),  # Remove background from legend keys
      legend.key.width = grid::unit(0.3, "cm"),
      legend.key.height = grid::unit(0.3, "cm"), 
      legend.key.size = grid::unit(0.3, "cm"),
      legend.spacing.y = grid::unit(0.05, "cm"),  # Tighter spacing
      legend.text = ggplot2::element_text(size = 7, face = "plain"),  # Smaller, not bold
      legend.title = ggplot2::element_blank(),
      
      # Make legend positioning more robust against patchwork interference
      legend.box.just = "left",
      
      # Axis styling - matching PCA sizes
      axis.title = ggplot2::element_text(size = 12.5, face = "bold", color = "black"),
      axis.title.x = ggplot2::element_text(size = 12.5, face = "bold", color = "black"),
      axis.title.y = ggplot2::element_text(size = 12.5, face = "bold", color = "black", margin = ggplot2::margin(r = 0), hjust = 0.5),
      axis.text = ggplot2::element_text(size = 11, face = "bold", color = "black"),
      
      # Use proper axis lines instead of panel border for better tick control
      axis.line = ggplot2::element_line(color = "black", linewidth = 0.5),
      axis.ticks = ggplot2::element_line(color = "black", linewidth = 0.5),
      axis.ticks.length = ggplot2::unit(0.15, "cm"),
      
      # Panel styling - clean background, no border since we use axis.line
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(), 
      panel.border = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank()
    ) +
    ggplot2::guides(color = ggplot2::guide_legend(
      override.aes = list(shape = 16, size = 0.75) # legend dots 1.5x larger than plot dots
    ))

  list(
    volcano_data = volcano_data,
    volcano_plot = volcano_plot
  )
}
