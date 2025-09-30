#' Create Pathway Enrichment Dot Plot
#'
#' This function creates a dot plot visualization for pathway enrichment results,
#' where dots represent pathways across different comparisons. Dot size corresponds 
#' to enrichment factors and dot color corresponds to p-values.
#'
#' @param nosev_pathways Data frame containing nosev pathway results
#' @param modsev_pathways Data frame containing modsev pathway results  
#' @param allsev_pathways Data frame containing allsev pathway results
#' @param p_method Character string specifying p-value method: "fisher", "gamma", or "both" (default "fisher")
#' @param enrichment_cap Numeric maximum value to cap enrichment factors (default 5)
#' @param size_range Numeric vector of length 2 for dot size range (default c(5, 10))
#' @param size_breaks Numeric vector for size scale breaks (auto-generated if NULL)
#' @param show_legend Logical indicating whether to show legends (default TRUE)
#' @param plot_title Optional title for the plot (default NULL). For "both" method, "_Fisher" or "_Gamma" will be appended
#' @param save_path Optional file path to save the plot (default NULL). For "both" method, "_fisher" or "_gamma" will be inserted before file extension
#' @param plot_width Numeric width for saved plot in inches (default NULL - auto-calculated)
#' @param plot_height Numeric height for saved plot in inches (default NULL - auto-calculated)
#' @param width_per_comparison Numeric width per comparison column in inches (default 0.3)
#' @param width_base Numeric base width in inches (default 7 with legend, 4.2 without)
#' @param height_per_pathway Numeric height per pathway row in inches (default 0.3)
#' @param height_base Numeric base height in inches (default 2)
#' @param dpi Numeric resolution for saved plot (default 600)
#'
#' @return A ggplot2 object (single plot) or list of ggplot2 objects (when method = "both")
#'
#' @examples
#' \dontrun{
#'   # Single Fisher plot
#'   fisher_plot <- plot_pathway_enrichment(
#'     nosev_pathways = mfn_nosev_pathways,
#'     modsev_pathways = mfn_modsev_pathways,
#'     allsev_pathways = mfn_allsev_pathways,
#'     p_method = "fisher",
#'     enrichment_cap = 5,
#'     size_range = c(5, 10),
#'     show_legend = TRUE
#'   )
#'   
#'   # Both Fisher and Gamma plots
#'   both_plots <- plot_pathway_enrichment(
#'     p_method = "both",
#'     save_path = "enrichment_plot.png", # Will create _fisher.png and _gamma.png
#'     plot_width = 10,
#'     plot_height = 8
#'   )
#' }
plot_pathway_enrichment <- function(
  nosev_pathways,
  modsev_pathways, 
  allsev_pathways,
  p_method = "fisher",
  enrichment_cap = 5,
  size_range = c(5, 10),
  size_breaks = NULL,
  show_legend = TRUE,
  plot_title = NULL,
  save_path = NULL,
  plot_width = NULL,
  plot_height = NULL,
  width_per_comparison = 0.3,
  width_base = NULL,
  height_per_pathway = 0.3,
  height_base = 2,
  dpi = 600
) {
  
  # Load required libraries
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(forcats)
  
  # Validate p_method
  if (!p_method %in% c("fisher", "gamma", "both")) {
    stop("p_method must be 'fisher', 'gamma', or 'both'")
  }
  
  # If method is "both", run function twice
  if (p_method == "both") {
    # Check that both columns exist
    fisher_exists <- "P(Fisher)" %in% names(nosev_pathways)
    gamma_exists <- "P(Gamma)" %in% names(nosev_pathways)
    
    if (!fisher_exists) {
      stop("P(Fisher) column not found in data")
    }
    if (!gamma_exists) {
      stop("P(Gamma) column not found in data")
    }
    
    # Create Fisher plot
    fisher_title <- if (!is.null(plot_title)) paste0(plot_title, " - Fisher") else NULL
    fisher_save_path <- if (!is.null(save_path)) {
      # Insert "_fisher" before file extension
      file_parts <- tools::file_path_sans_ext(save_path)
      file_ext <- tools::file_ext(save_path)
      paste0(file_parts, "_fisher.", file_ext)
    } else NULL
    
    fisher_plot <- plot_pathway_enrichment(
      nosev_pathways = nosev_pathways,
      modsev_pathways = modsev_pathways,
      allsev_pathways = allsev_pathways,
      p_method = "fisher",
      enrichment_cap = enrichment_cap,
      size_range = size_range,
      size_breaks = size_breaks,
      show_legend = show_legend,
      plot_title = fisher_title,
      save_path = fisher_save_path,
      plot_width = plot_width,
      plot_height = plot_height,
      width_per_comparison = width_per_comparison,
      width_base = width_base,
      height_per_pathway = height_per_pathway,
      height_base = height_base,
      dpi = dpi
    )
    
    # Create Gamma plot
    gamma_title <- if (!is.null(plot_title)) paste0(plot_title, " - Gamma") else NULL
    gamma_save_path <- if (!is.null(save_path)) {
      # Insert "_gamma" before file extension
      file_parts <- tools::file_path_sans_ext(save_path)
      file_ext <- tools::file_ext(save_path)
      paste0(file_parts, "_gamma.", file_ext)
    } else NULL
    
    gamma_plot <- plot_pathway_enrichment(
      nosev_pathways = nosev_pathways,
      modsev_pathways = modsev_pathways,
      allsev_pathways = allsev_pathways,
      p_method = "gamma",
      enrichment_cap = enrichment_cap,
      size_range = size_range,
      size_breaks = size_breaks,
      show_legend = show_legend,
      plot_title = gamma_title,
      save_path = gamma_save_path,
      plot_width = plot_width,
      plot_height = plot_height,
      width_per_comparison = width_per_comparison,
      width_base = width_base,
      height_per_pathway = height_per_pathway,
      height_base = height_base,
      dpi = dpi
    )
    
    return(list(fisher = fisher_plot, gamma = gamma_plot))
  }
  
  # Convert method to column name
  p_column <- switch(p_method,
    "fisher" = "P(Fisher)",
    "gamma" = "P(Gamma)"
  )
  
  # Validate p_column exists in data
  if (!p_column %in% names(nosev_pathways)) {
    stop("P-value column '", p_column, "' not found in nosev_pathways")
  }
  if (!p_column %in% names(modsev_pathways)) {
    stop("P-value column '", p_column, "' not found in modsev_pathways")
  }
  if (!p_column %in% names(allsev_pathways)) {
    stop("P-value column '", p_column, "' not found in allsev_pathways")
  }
  
  # Clean and standardize each dataset
  nosev_clean <- nosev_pathways %>%
    mutate(
      Comparisons = "nosev",
      p_fisher = as.numeric(.data[[p_column]]),
      enrichment_factor = Hits.sig / Expected
    ) %>%
    select(Comparisons, pathway_name, p_fisher, enrichment_factor)
  
  modsev_clean <- modsev_pathways %>%
    mutate(
      Comparisons = "modsev", 
      p_fisher = as.numeric(.data[[p_column]]),
      enrichment_factor = Hits.sig / Expected
    ) %>%
    select(Comparisons, pathway_name, p_fisher, enrichment_factor)
  
  allsev_clean <- allsev_pathways %>%
    mutate(
      Comparisons = "allsev",
      p_fisher = as.numeric(.data[[p_column]]),
      enrichment_factor = Hits.sig / Expected
    ) %>%
    select(Comparisons, pathway_name, p_fisher, enrichment_factor)
  
  # Combine datasets and process
  enrichment_data <- bind_rows(nosev_clean, modsev_clean, allsev_clean) %>%
    tidyr::complete(pathway_name, Comparisons) %>%
    filter(p_fisher < 0.05) %>%
    mutate(
      Comparisons = dplyr::case_when(
        Comparisons == "nosev" ~ "No vs. Severe PGD",
        Comparisons == "modsev" ~ "Mild/Mod vs. Severe PGD", 
        Comparisons == "allsev" ~ "No+Mild/Mod vs. Severe PGD",
        TRUE ~ Comparisons
      ),
      Comparisons = factor(Comparisons, levels = c("No vs. Severe PGD", "Mild/Mod vs. Severe PGD", "No+Mild/Mod vs. Severe PGD")),
      pathway_name = forcats::fct_reorder(pathway_name, enrichment_factor, .fun = max)
    ) %>%
    # Apply enrichment factor cap
    mutate(enrichment_factor = pmin(enrichment_factor, enrichment_cap)) %>%
    # Reorder pathways by allsev comparison enrichment
    mutate(
      pathway_name = factor(
        pathway_name,
        levels = {
          allsev_order <- filter(., Comparisons == "No+Mild/Mod vs. Severe PGD" & !is.na(enrichment_factor)) %>%
            arrange(desc(enrichment_factor)) %>%
            pull(pathway_name) %>%
            unique()
          all_pathways <- unique(.$pathway_name)
          remaining_pathways <- setdiff(all_pathways, allsev_order)
          c(allsev_order, remaining_pathways)
        }
      )
    )
  
  # Auto-generate size breaks if not provided
  if (is.null(size_breaks)) {
    size_breaks <- pretty(c(0, enrichment_cap), n = 4)
    size_breaks <- size_breaks[size_breaks <= enrichment_cap & size_breaks > 0]
  }
  
  # Handle conflicts preference
  conflicted::conflicts_prefer(ggplot2::margin)
  
  # Create the plot
  p <- ggplot(
    enrichment_data,
    aes(x = 0.5, y = 0.5, size = enrichment_factor, color = p_fisher)
  ) +
    geom_tile(
      data = data.frame(x = 0.5, y = 0.5),
      aes(x = x, y = y),
      width = 1, height = 1,
      fill = "white", colour = "grey80", linewidth = 0.3,
      inherit.aes = FALSE
    ) +
    geom_point(
      alpha = 0.95, shape = 16, stroke = 0,
      na.rm = TRUE, show.legend = show_legend
    ) +
    facet_grid(
      rows = vars(pathway_name),
      cols = vars(Comparisons),
      switch = "y", drop = FALSE
    ) +
    coord_fixed(clip = "off") +
    scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
    scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    scale_size_continuous(
      range = size_range,
      limits = c(0, enrichment_cap),
      breaks = size_breaks,
      name = "Enrichment factor",
      guide = if (show_legend) guide_legend(reverse = TRUE) else "none"
    ) +
    scale_color_gradient(
      low = "#0a2256", high = "#c3dbe9",
      limits = c(0.01, 0.05),
      oob = scales::squish,
      name = "p-value\n",
      guide = if (show_legend) {
        guide_colorbar(
          reverse = TRUE,
          barheight = unit(5, "cm"),
          barwidth = unit(0.9, "cm")
        )
      } else {
        "none"
      }
    ) +
    labs(x = NULL, y = NULL, title = plot_title) +
    theme_minimal(base_family = "Arial") +
    theme(
      text = element_text(family = "Arial"),
      panel.grid = element_blank(),
      panel.background = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.spacing.x = unit(0, "pt"),
      panel.spacing.y = unit(0, "pt"),
      strip.placement = "outside",
      strip.text.x.top = element_text(
        angle = 90, vjust = 0.3, hjust = 0,
        face = "bold", family = "Arial", size = 12, margin = margin(l = -14, b = 5)
      ),
      strip.text.y.left = element_text(
        angle = 0, hjust = 1,
        face = "bold", family = "Arial", size = 12,
        margin = margin(r = 6)
      ),
      legend.title = element_text(size = 12, face = "bold", family = "Arial"),
      legend.text = element_text(size = 12, family = "Arial"),
      plot.margin = margin(t = 20, r = 40, b = 10, l = 40)
    ) +
    coord_cartesian(clip = "off")
  
  # Hide legends if requested
  if (!show_legend) {
    p <- p + theme(legend.position = "none")
  }
  
  # Save plot if path provided
  if (!is.null(save_path)) {
    # Calculate dynamic dimensions based on data
    n_comparisons <- length(unique(enrichment_data$Comparisons))
    n_pathways <- length(unique(enrichment_data$pathway_name))
    
    # Set width_base default if not provided
    if (is.null(width_base)) {
      width_base <- if (show_legend) 7 else 4.2
    }
    
    # Calculate dimensions
    if (is.null(plot_width)) {
      calc_width <- n_comparisons * width_per_comparison + width_base
    } else {
      calc_width <- plot_width
    }
    
    if (is.null(plot_height)) {
      calc_height <- n_pathways * height_per_pathway + height_base
      # Add extra height for large pathway lists
      if (n_pathways > 20) {
        calc_height <- calc_height + 2
      }
    } else {
      calc_height <- plot_height
    }
    
    ggsave(
      save_path,
      p,
      width = calc_width,
      height = calc_height,
      units = "in",
      dpi = dpi
    )
    
    message("Plot saved to: ", save_path, " (", calc_width, " x ", calc_height, " inches)")
  }
  
  return(p)
}
