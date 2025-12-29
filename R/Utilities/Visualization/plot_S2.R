#' Generate Multi-Page Supplementary Figure S2 with Volcano Plots
#'
#' Creates a multi-page supplementary figure with volcano plots arranged in a grid layout.
#' Each page contains a specified number of plots with consistent positioning and annotation.
#' Designed for creating publication-ready supplemental materials with multiple metabolomic
#' analyses or comparisons.
#'
#' @param annot_df Data frame containing annotation information for the plots
#' @param plots List of ggplot objects (typically volcano plots) to arrange across pages
#' @param n_cols Number of columns per page (default: 4)
#' @param n_rows Number of rows per page (default: 5)
#' @param plot_width Width of individual plots in inches (default: 1.75)
#' @param plot_height Height of individual plots in inches (default: 1.75)
#' @param x_from Left margin for plot positioning in inches (default: 0.6475)
#' @param x_to Right margin for plot positioning in inches (default: 6.0975)
#' @param y_from Top margin for plot positioning in inches (default: 8.5)
#' @param y_to Bottom margin for plot positioning in inches (default: 0.465)
#' @param page_width Total page width in inches (default: 8.5)
#' @param page_height Total page height in inches (default: 11)
#'
#' @return List containing:
#'   - pages: List of cowplot objects, one per page
#'   - position_mapping: Data frame mapping plot indices to page and position
#'
#' @details
#' The function automatically calculates how many pages are needed based on the number
#' of plots and the specified grid dimensions. Plots are arranged left-to-right,
#' top-to-bottom within each page. The positioning parameters allow for precise
#' control over plot placement for publication formatting.
#'
#' @examples
#' \dontrun{
#'   # Create volcano plots for different comparisons
#'   volcano_plots <- list(plot1, plot2, plot3, ...)
#'   
#'   # Generate multi-page figure
#'   s2_figure <- plot_S2(
#'     annot_df = annotations,
#'     plots = volcano_plots,
#'     n_cols = 4,
#'     n_rows = 5
#'   )
#'   
#'   # Access individual pages
#'   page1 <- s2_figure$pages[[1]]
#' }
#'
#' @importFrom ggplot2 ggplot
#' @importFrom cowplot plot_grid
#' @importFrom dplyr %>%
#' @export
plot_S2 <- function(
    annot_df,
    plots,
    n_cols = 4,
    n_rows = 5,
    plot_width = 1.75,
    plot_height = 1.6,
    x_from = 0.6475,
    x_to = 6.0975,
    y_from = 7.5,
    y_to = 0.465,
    page_width = 8.5,
    page_height = 11
) {
  # ---- required libs ----
  library(ggplot2)
  library(cowplot)
  library(dplyr)

  # ---- layout constants ----
  plots_per_page <- n_cols * n_rows
  x_positions <- seq(from = x_from, to = x_to, length.out = n_cols)
  # Keep top row in original position, compress spacing equally for all rows below
  original_spacing <- (y_from - y_to) / (n_rows - 1)  # Original spacing between rows
  compressed_spacing <- original_spacing - 0.15  # Compress spacing by 0.35 inches
  new_y_to <- y_from - compressed_spacing * (n_rows - 1)  # New bottom position
  y_positions <- seq(from = y_from, to = new_y_to, length.out = n_rows)
  n_pages <- ceiling(length(plots) / plots_per_page)

  # ---- create position mapping for all plots ----
  sig_orders_df <- data.frame(
    sig_ord = names(plots),
    plot_index = seq_along(plots)
  ) %>%
    dplyr::mutate(
      page_num = ceiling(plot_index / plots_per_page),
      plot_on_page = ((plot_index - 1) %% plots_per_page) + 1,
      row_num = ceiling(plot_on_page / n_cols),
      col_num = ((plot_on_page - 1) %% n_cols) + 1
    )

  # ---- helper to build each page of plots ----
  make_page <- function(page_index) {
    start_i <- (page_index - 1) * plots_per_page + 1
    end_i <- min(page_index * plots_per_page, length(plots))
    these_plots <- plots[start_i:end_i]
    
    # Strip x-axis labels from all plots
    these_plots <- lapply(these_plots, function(plot) {
      plot + theme(axis.title.x = element_blank())
    })

    page <- ggdraw(xlim = c(0, page_width), ylim = c(0, page_height))
    for (i in seq_along(these_plots)) {
      row <- ceiling(i / n_cols) - 1
      col <- (i - 1) %% n_cols
      page <- page +
        draw_plot(
          these_plots[[i]],
          x = x_positions[col + 1],
          y = y_positions[row + 1],
          width = plot_width,
          height = plot_height
        )
    }

    # label <- sprintf("Supplementary Figure S2.%d", page_index)
    page 
    #  figure_labels(setNames(list(c(0.49, 10.43)), label), fontface = "italic")
  }

  # ---- make all pages ----
  sup_figs <- lapply(seq_len(n_pages), make_page)

  # Create position mapping: sig_ord joined with page, row, column
  position_mapping <- sig_orders_df %>%
    dplyr::mutate(
      sig_ord = as.numeric(sig_ord),
      page = page_num,
      row = row_num,
      column = col_num
    ) %>%
    dplyr::select(sig_ord, page, row, column)
  
  # ---- return pages and position mapping ----
  return(list(
    pages = sup_figs,
    pg.row.col = position_mapping
  ))
}
