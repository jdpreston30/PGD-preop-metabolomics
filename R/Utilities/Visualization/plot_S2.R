#' Generate Multi-Page Supplemental Figure S2
#' @param annot_df Annotation data frame
#' @param plots List of plots to arrange
#' @param n_cols Number of columns per page (default: 4)
#' @param n_rows Number of rows per page (default: 5)
#' @param page_width Page width (default: 8.5)
#' @param page_height Page height (default: 11)
#' @return List with pages and position mapping
#' @export
plot_S2 <- function(
    annot_df,
    plots,
    n_cols = 4,
    n_rows = 5,
    plot_width = 1.75,
    plot_height = 1.75,
    x_from = 0.6475,
    x_to = 6.0975,
    y_from = 8.5,
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
  y_positions <- seq(from = y_from, to = y_to, length.out = n_rows)
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

    label <- sprintf("Supplemental Figure 2 (Page %d)", page_index)
    page + figure_labels(setNames(list(c(0.49, 10.43)), label))
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
