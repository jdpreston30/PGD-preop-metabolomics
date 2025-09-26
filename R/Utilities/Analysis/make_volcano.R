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
  
  # ---- Data preparation ----
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
  
  # ---- Perform t-tests ----
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
  
  # ---- Create volcano data ----
  volcano_data <- ttest_results
  volcano_data$neg_log10_p <- -log10(volcano_data$p_value)
  
  # Classify significance
  volcano_data$Legend <- "Not Significant"
  volcano_data$Legend[volcano_data$p_value < p_threshold & volcano_data$log2_fc > fc_threshold] <- 
    paste("Up in", group_names[2])
  volcano_data$Legend[volcano_data$p_value < p_threshold & volcano_data$log2_fc < -fc_threshold] <- 
    paste("Down in", group_names[2])
  
  volcano_data$Legend <- factor(volcano_data$Legend, 
                               levels = c("Not Significant", 
                                         paste("Up in", group_names[2]),
                                         paste("Down in", group_names[2])))
  
  # ---- Handle axis limits and warnings ----
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
  
  # ---- Create plot ----
  volcano_plot <- ggplot2::ggplot(
    volcano_data,
    ggplot2::aes(x = log2_fc, y = neg_log10_p, color = Legend)
  ) +
    ggplot2::geom_point(size = 2, na.rm = TRUE) +
    ggplot2::scale_color_manual(
      values = setNames(c("gray70", up_color, down_color), 
                       c("Not Significant", 
                         paste("Up in", group_names[2]),
                         paste("Down in", group_names[2]))),
      name = NULL
    ) +
    ggplot2::theme_light(base_family = "Arial") +
    ggplot2::labs(
      x = expression(log[2]("Fold Change")),
      y = expression(-log[10](p))
    ) +
    ggplot2::geom_hline(yintercept = -log10(p_threshold), linetype = "dashed", color = "black") +
    ggplot2::geom_vline(xintercept = c(-fc_threshold, fc_threshold), linetype = "dashed", color = "black") +
    ggplot2::scale_x_continuous(
      limits = x_range
    ) +
    ggplot2::scale_y_continuous(
      limits = y_range
    ) +
    ggplot2::theme(
      # Axis titles and labels
      axis.title.x = ggplot2::element_text(size = 15, face = "bold", color = "black"),
      axis.title.y = ggplot2::element_text(size = 15, face = "bold", color = "black"),
      axis.text.x = ggplot2::element_text(size = 12, face = "bold", color = "black"),
      axis.text.y = ggplot2::element_text(size = 12, face = "bold", color = "black"),
      legend.position = "none", # ✅ hides all legends

      # # Legend
      # legend.position = c(0.05, 0.95), # top-left inside plot
      # legend.justification = c("left", "top"),
      # legend.background = ggplot2::element_rect(fill = alpha("white", 0.7), color = NA),
      # legend.key = ggplot2::element_blank(),
      # legend.title = ggplot2::element_blank(),
      # legend.text = ggplot2::element_text(size = 10, face = "bold", color = "black"),

      # General
      strip.text = ggplot2::element_text(size = 12, face = "bold", color = "black"),
      panel.border = ggplot2::element_rect(color = "black", fill = NA, linewidth = 1.2),
      axis.ticks = ggplot2::element_blank()
    ) +
    ggplot2::guides(color = ggplot2::guide_legend(
      override.aes = list(shape = 16, size = 3) # legend dots smaller
    ))

  list(
    volcano_data = volcano_data,
    volcano_plot = volcano_plot
  )
}
