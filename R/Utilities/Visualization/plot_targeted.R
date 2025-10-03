#' Create Individual Feature Bar Plots for T-test Results
#'
#' This function creates publication-style bar plots for individual metabolomic features
#' showing group comparisons with means, individual data points, and statistical results.
#' Specifically designed for severe_PGD analysis.
#'
#' @param ttest_results Tibble output from run_targeted_ttests() function
#' @param feature_data Data frame with feature values (samples as rows, features as columns)
#' @param plot_mode Which features to plot: "all" (all features), "sig_p" (p < 0.05), "fdr_p" (FDR < 0.05)
#' @param base_family Font family for plots (default: "Arial")
#' @param include_individual_points Whether to show individual data points (default: TRUE)
#' @param jitter_width Width of jitter for individual points (default: 0.15)
#' @param significance_threshold P-value threshold for significance (default: 0.05)
#' @param show_significance_bars Whether to show significance bars/stars (default: TRUE)
#' @param print_p Whether to print p-value in top right corner (default: FALSE)
#' @param print_p_fdr Whether to print FDR-adjusted p-value instead of raw p-value (default: FALSE)
#' @param undo_log Whether to undo log2 transformation (2^x) for display (default: FALSE)
#'
#' @return List of ggplot objects, one for each feature
#'
#' @examples
#' \dontrun{
#'   # First run the t-tests
#'   ttest_results <- run_targeted_ttests(
#'     feature_table = TFT,
#'     tft_key = TFT_key
#'   )
#'   
#'   # Plot only FDR significant features (default)
#'   plots_fdr <- plot_targeted(
#'     ttest_results = ttest_results,
#'     feature_data = TFT,
#'     plot_mode = "fdr_p"
#'   )
#'   
#'   # Plot all features with p < 0.05
#'   plots_sig <- plot_targeted(
#'     ttest_results = ttest_results,
#'     feature_data = TFT,
#'     plot_mode = "sig_p"
#'   )
#'   
#'   # Plot ALL features in dataset
#'   plots_all <- plot_targeted(
#'     ttest_results = ttest_results,
#'     feature_data = TFT,
#'     plot_mode = "all"
#'   )
#'   
#'   # View individual plot
#'   print(plots_fdr[[1]])
#' }
#'
#' @export
plot_targeted <- function(ttest_results,
                          feature_data,
                          plot_mode = "fdr_p",
                          base_family = "Arial",
                          include_individual_points = TRUE,
                          jitter_width = 0.15,
                          significance_threshold = 0.05,
                          show_significance_bars = TRUE,
                          print_p = FALSE,
                          print_p_fdr = FALSE,
                          undo_log = FALSE) {
  
  # Load required libraries
  library(dplyr)
  library(ggplot2)
  library(purrr)
  library(stringr)
  
  # Filter ttest_results based on plot_mode
  if (plot_mode == "all") {
    filtered_results <- ttest_results
    cat("Plotting all", nrow(filtered_results), "features\n")
  } else if (plot_mode == "sig_p") {
    filtered_results <- ttest_results %>%
      filter(!is.na(p_value) & p_value < 0.05)
    cat("Plotting", nrow(filtered_results), "features with p < 0.05\n")
  } else if (plot_mode == "fdr_p") {
    filtered_results <- ttest_results %>%
      filter(!is.na(p_value_fdr) & p_value_fdr < 0.05)
    cat("Plotting", nrow(filtered_results), "features with FDR < 0.05\n")
  } else {
    stop("plot_mode must be one of: 'all', 'sig_p', 'fdr_p'")
  }
  
  if (nrow(filtered_results) == 0) {
    warning("No features meet the criteria for plot_mode = '", plot_mode, "'")
    return(list())
  }
  
  # Set dynamic y-label based on undo_log parameter with proper subscript
  y_label <- if (undo_log) {
    "Spectral Intensity"
  } else {
    expression(Log[2]~Intensity)
  }
  
  # Hardcoded for severe_PGD analysis
  grouping_var_name <- "severe_PGD"
  group_vector <- feature_data$severe_PGD
  
  # Convert to factor if not already
  if (!is.factor(group_vector)) {
    group_vector <- as.factor(group_vector)
  }
  
  # Get group levels and map colors
  group_levels <- levels(group_vector)
  
  # Color mapping: "Severe PGD" = red, "No Severe PGD" = blue
  group_colors <- setNames(c("#800017", "#113d6a"), c("Severe PGD", "No Severe PGD"))
  group_colors_light <- setNames(c("#D8919A", "#87A6C7"), c("Severe PGD", "No Severe PGD"))
  
  # Display labels: "Severe PGD" → "Y", "No Severe PGD" → "N"
  display_labels <- c("Severe PGD" = "Y", "No Severe PGD" = "N")
  x_axis_title <- "Severe PGD"
  
  # Publication-style theme (matching volcano plot styling exactly)
  theme_pub_barplot <- function() {
    theme_minimal(base_family = base_family) +
      theme(
        # Panel styling - clean background, keep only bottom and left axes lines
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        panel.background = element_blank(),
        axis.line.x.bottom = element_line(color = "black", linewidth = 0.6),
        axis.line.y.left = element_line(color = "black", linewidth = 0.6),
        
        # Axis styling - matching volcano plot exactly
        axis.ticks = element_line(color = "black", linewidth = 0.6),
        axis.ticks.length = unit(0.15, "cm"),
        axis.text = element_text(size = 11, face = "bold", color = "black"),
        axis.text.x = element_text(size = 11, face = "bold", color = "black", angle = 0, vjust = 0.5, hjust = 0.5),  # Straight labels
        axis.text.y = element_text(size = 11, face = "bold", color = "black"),
        axis.title = element_text(size = 12.5, face = "bold", color = "black"),
        axis.title.x = element_text(size = 12.5, face = "bold", color = "black", margin = margin(t = 5)),
        axis.title.y = element_text(size = 12.5, face = "bold", color = "black", margin = margin(r = 5), hjust = 0.5),
        
        # Plot title - matching volcano styling
        plot.title = element_text(size = 12.5, face = "bold", hjust = 0.5, color = "black"),
        
        # Legend (will be hidden for individual plots)
        legend.position = "none"
      )
  }
  
  # Function to format feature names nicely
  format_feature_name <- function(feature_name) {
    # Remove long suffixes and make more readable
    clean_name <- str_replace(feature_name, "^(C18_|HILIC_)", "")
    clean_name <- str_replace(clean_name, "_.*", "")  # Remove everything after first underscore for brevity
    return(clean_name)
  }
  
  # Function to create individual feature plot
  create_single_feature_plot <- function(feature_name) {
    # Check if feature exists in results
    if (!feature_name %in% ttest_results$feature) {
      warning("Feature '", feature_name, "' not found in ttest_results")
      return(NULL)
    }
    
    # Get feature values
    if (!feature_name %in% colnames(feature_data)) {
      warning("Feature '", feature_name, "' not found in feature_data")
      return(NULL)
    }
    
    # Prepare plotting data
    plot_data <- data.frame(
      Group = group_vector,
      Feature_Value = feature_data[[feature_name]],
      stringsAsFactors = FALSE
    ) %>%
      filter(!is.na(Feature_Value), !is.na(Group)) %>%
      mutate(
        Group = factor(Group, levels = group_levels),
        # Apply undo_log transformation if requested
        Feature_Value = if (undo_log) 2^Feature_Value else Feature_Value
      )
    
    # Calculate summary statistics
    summary_data <- plot_data %>%
      group_by(Group) %>%
      summarise(
        mean_value = mean(Feature_Value, na.rm = TRUE),
        se_value = sd(Feature_Value, na.rm = TRUE) / sqrt(n()),
        max_value = max(Feature_Value, na.rm = TRUE),
        n_samples = n(),
        .groups = "drop"
      )
    
    # Get p-value for this feature from filtered results
    feature_results <- filtered_results %>%
      filter(feature == feature_name)
    
    if (nrow(feature_results) == 0) {
      p_value <- NA
      p_value_fdr <- NA
    } else {
      p_value <- feature_results$p_value[1]
      p_value_fdr <- if("p_value_fdr" %in% colnames(feature_results)) {
        feature_results$p_value_fdr[1]
      } else {
        NA
      }
    }
    
    # Choose which p-value to display based on parameters
    display_p_value <- if (print_p_fdr && !is.na(p_value_fdr)) {
      p_value_fdr
    } else {
      p_value
    }
    
    # Create p-value text for title (only if show_significance_bars is TRUE) - NOT USED ANYMORE
    p_text <- ""  # P-values no longer go in title
    
    # Get feature display name (use identified_name if available, otherwise format feature_name)
    feature_display_name <- if (nrow(feature_results) > 0 && "identified_name" %in% colnames(feature_results)) {
      identified_name <- feature_results$identified_name[1]
      if (!is.na(identified_name) && identified_name != "" && identified_name != "Unknown") {
        identified_name
      } else {
        format_feature_name(feature_name)
      }
    } else {
      format_feature_name(feature_name)
    }
    
    # Determine significance
    is_significant <- !is.na(p_value) && p_value < significance_threshold
    
    # Determine y limits for plot
    y_max <- max(summary_data$max_value, na.rm = TRUE)
    y_limit <- y_max * 1.15  # Add space for title
    
    # Create the base plot
    p <- ggplot() +
      # Add bars with group colors (matching volcano styling)
      geom_col(
        data = summary_data,
        aes(x = Group, y = mean_value, fill = Group, color = Group),
        width = 0.7, 
        linewidth = 0.6,  # Match volcano plot linewidth
        alpha = 0.8, 
        na.rm = TRUE
      ) +
      # Add mean points for emphasis
      geom_point(
        data = summary_data,
        aes(x = Group, y = mean_value, color = Group),
        size = 1.5,
        shape = 16
      )
    
    # Add individual data points if requested
    if (include_individual_points) {
      p <- p + geom_jitter(
        data = plot_data,
        aes(x = Group, y = Feature_Value, color = Group),
        width = jitter_width, 
        size = 0.6, 
        alpha = 0.7, 
        show.legend = FALSE
      )
    }
    
    # Apply color scales and theme
    p <- p +
      scale_fill_manual(values = group_colors_light, drop = FALSE) +
      scale_color_manual(values = group_colors, drop = FALSE) +
      scale_x_discrete(labels = display_labels) +  # Use custom display labels
      scale_y_continuous(
        expand = expansion(mult = c(0, 0.05)), 
        limits = c(0, y_limit)
      ) +
      theme_pub_barplot() +
      labs(
        x = x_axis_title,  # Conditional x-axis title
        y = y_label,
        title = feature_display_name  # Just the identified name, no p-values
      )
    
    # Add p-value annotation in top right corner if requested
    if ((print_p || print_p_fdr) && !is.na(display_p_value)) {
      p_annotation_text <- if (print_p_fdr && !is.na(p_value_fdr)) {
        if (p_value_fdr < 0.001) "FDR < 0.001" else paste0("FDR = ", round(p_value_fdr, 3))
      } else {
        if (display_p_value < 0.001) "p < 0.001" else paste0("p = ", round(display_p_value, 3))
      }
      
      p <- p + annotate("text", 
                       x = Inf, y = Inf, 
                       label = p_annotation_text,
                       hjust = 1.1, vjust = 1.3,
                       size = 3, 
                       fontface = "italic",
                       color = "black")
    }
    
    # Modify title color based on significance
    if (is_significant) {
      p <- p + theme(plot.title = element_text(color = "black"))
    } else {
      p <- p + theme(plot.title = element_text(color = "gray50"))
    }
    
    return(p)
  }
  
  # Get all features from filtered results
  features_to_plot <- unique(filtered_results$feature)
  
  # Create plots for all features
  cat("Creating", length(features_to_plot), "feature plots...\n")
  
  feature_plots <- map(features_to_plot, create_single_feature_plot)
  names(feature_plots) <- features_to_plot
  
  # Remove any NULL plots (from errors)
  feature_plots <- feature_plots[!map_lgl(feature_plots, is.null)]
  
  cat("Successfully created", length(feature_plots), "plots\n")
  
  return(feature_plots)
}

#' Create Feature Plot Grid Pages
#'
#' Arranges individual feature plots into grid pages for easy viewing
#'
#' @param feature_plots List of ggplot objects from create_feature_barplots()
#' @param plots_per_page Number of plots per page (default: 9 for 3x3 grid)
#' @param ncol Number of columns in grid (default: 3)
#' @param page_title_base Base title for pages (default: "Feature Analysis")
#' @param sort_by_pvalue Whether to sort plots by p-value (default: TRUE)
#' @param ttest_results Optional ttest results for sorting (required if sort_by_pvalue = TRUE)
#'
#' @return List of grid objects, one per page
#'
#' @export
create_feature_plot_pages <- function(feature_plots,
                                     plots_per_page = 9,
                                     ncol = 3,
                                     page_title_base = "Feature Analysis",
                                     sort_by_pvalue = TRUE,
                                     ttest_results = NULL) {
  
  library(cowplot)
  
  # Sort plots by p-value if requested
  if (sort_by_pvalue && !is.null(ttest_results)) {
    # Get feature order by p-value
    feature_order <- ttest_results %>%
      arrange(p_value) %>%
      pull(feature)
    
    # Reorder plots
    feature_plots <- feature_plots[feature_order[feature_order %in% names(feature_plots)]]
  }
  
  # Split plots into chunks
  plot_chunks <- split(feature_plots, ceiling(seq_along(feature_plots) / plots_per_page))
  
  # Create page grid function
  create_page_grid <- function(chunk_plots, page_num, total_pages) {
    nrow <- ceiling(length(chunk_plots) / ncol)
    
    # Create title
    title_text <- paste0(page_title_base, " - Page ", page_num, " of ", total_pages)
    
    # Create title plot
    title_plot <- ggplot() +
      geom_text(aes(x = 0.5, y = 0.5), label = title_text, 
                size = 5, fontface = "bold", hjust = 0.5, vjust = 0.5) +
      xlim(0, 1) + ylim(0, 1) +
      theme_void() +
      theme(plot.background = element_rect(fill = "white", color = NA))
    
    # Create plot grid
    plot_grid_obj <- plot_grid(plotlist = chunk_plots, nrow = nrow, ncol = ncol)
    
    # Combine title and plots
    final_page <- plot_grid(title_plot, plot_grid_obj, 
                           nrow = 2, ncol = 1, 
                           rel_heights = c(0.1, 0.9))
    
    return(final_page)
  }
  
  # Create all pages
  pages <- map2(plot_chunks, seq_along(plot_chunks), 
                ~create_page_grid(.x, .y, length(plot_chunks)))
  
  cat("Created", length(pages), "pages with", plots_per_page, "plots each\n")
  
  return(pages)
}