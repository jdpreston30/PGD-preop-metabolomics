#' Plot Enrichment Network
#'
#' This function creates a network plot from enrichment graph data,
#' where nodes represent pathways and edges represent similarity based on shared compounds.
#' Node colors correspond to p-values, and node sizes correspond to enrichment factors.
#'
#' @param graph_data Results from build_enrichment_network function
#' @param save_path Optional file path to save the plot (default NULL).
#' @param plot_title Optional title for the plot (default NULL).
#' @param width Numeric width of saved plot in units (default 8).
#' @param height Numeric height of saved plot in units (default 6).
#' @param dpi Numeric resolution for saved plot (default 300).
#' @param units Units for width and height when saving (default "in").
#' @param bg Background color for saved plot (default "white").
#' @param seed Integer seed for reproducible layout (default 123).
#' @param layout Layout algorithm for graph plotting (default "fr").
#' @param p_limits Numeric vector of length 2 specifying limits for the p-value color scale (default c(0.01, 0.05)).
#' @param show_enrichment Logical to toggle the enrichment factor legend (default TRUE).
#' @param show_pvalue Logical to toggle the p-value legend (default TRUE).
#'
#' @return The ggplot2 object of the enrichment network.
#'
#' @examples
#' \dontrun{
#'   # Assuming graph_data is from build_enrichment_network
#'   plot <- plot_enrichment_network(graph_data)
#'   print(plot)
#' }
plot_enrichment_network <- function(
    graph_data,
    save_path = NULL,
    plot_title = NULL,
    width = 8, height = 6, dpi = 300, units = "in", bg = "white",
    seed = 123, layout = "fr",
    p_limits = c(0.01, 0.05),
    show_enrichment = TRUE,   # NEW: toggle enrichment factor legend
    show_pvalue     = TRUE    # NEW: toggle p-value legend
) {
  pkgs <- c("ggraph", "scales", "ggplot2", "grid", "igraph")
  missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing)) stop("Install missing packages: ", paste(missing, collapse = ", "))

  # Extract data from graph_data
  g <- graph_data$graph
  
  # ---- Compute layout coordinates ----
  set.seed(seed)
  coords <- switch(
    layout,
    fr = igraph::layout_with_fr(g),
    kk = igraph::layout_with_kk(g),
    lgl = igraph::layout_with_lgl(g),
    circle = igraph::layout_in_circle(g),
    grid = igraph::layout_on_grid(g),
    stop("Unsupported layout: ", layout)
  )
  coords_df <- as.data.frame(coords)
  colnames(coords_df) <- c("x", "y")
  coords_df$name <- igraph::V(g)$name

  # ---- PLOT ----
  p <- ggraph::ggraph(g, layout = coords_df) +
    ggraph::geom_edge_link(aes(width = weight), alpha = 0.5, colour = "grey50") +

    # Nodes
    ggraph::geom_node_point(aes(size = size_val, fill = p_val),
      shape = 21, stroke = 0.6, colour = "black"
    ) +

    # Labels
    ggraph::geom_node_text(aes(label = Name),
      size = 4, colour = "black",
      family = "Arial", fontface = "bold",
      vjust = 2.2
    ) +

    ggraph::scale_edge_width(range = c(0.2, 2), guide = "none") +
    theme_void(base_family = "Arial") +
    theme(
      legend.position = "right",
      legend.margin   = margin(l = 40, r = 0, t = 0, b = 0),
      legend.text     = element_text(size = 13, face = "bold", family = "Arial"),
      legend.title    = element_text(size = 14, face = "bold", family = "Arial"),
      text            = element_text(color = "black", family = "Arial")
    ) +
    ggplot2::coord_equal(clip = "off") +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.07)) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0.07)) +
    {if (!is.null(plot_title)) ggplot2::labs(title = plot_title)} +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        size   = 25,
        face   = "bold",
        family = "Arial",
        hjust  = 0.5,
        vjust  = 5
      ),
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    )

  # --- Conditional legends ---
  p <- p +
    scale_size_continuous(
      range = c(3, 30),
      limits = c(0, 5),
      breaks = c(4, 3, 2, 1),
      name = "\nEnrichment factor",
      guide = if (show_enrichment) {
        guide_legend(
          reverse = TRUE,
          override.aes = list(fill = "black", colour = "black")
        )
      } else {
        "none"
      }
    )

  p <- p +
    scale_fill_gradient(
      low = "#0a2256", high = "#c3dbe9",
      limits = p_limits, oob = scales::squish,
      name = "p-value\n",
      guide = if (show_pvalue) {
        guide_colorbar(
          reverse   = TRUE,
          barheight = grid::unit(8, "cm"),
          barwidth  = grid::unit(1.3, "cm")
        )
      } else {
        "none"
      }
    )

  # --- Saving ---
  if (!is.null(save_path)) {
    ggplot2::ggsave(
      filename = save_path, plot = p,
      width = width, height = height,
      dpi = dpi, units = units, bg = bg
    )
  }

  return(p)
}