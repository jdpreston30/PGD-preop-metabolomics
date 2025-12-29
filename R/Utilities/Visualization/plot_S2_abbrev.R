#' Generate Abbreviation Table for Supplementary Figure S2
#'
#' Creates a formatted table displaying abbreviations and their definitions for use
#' in supplementary figures. The table uses a clean, publication-ready format with
#' customizable styling, column widths, and export options.
#'
#' @param table_data Data frame containing abbreviation information with columns
#'   for abbreviations and their corresponding definitions
#' @param col_widths Numeric vector specifying the width of each column in inches
#'   (default: c(1.2, 1.65, 3.575))
#' @param header_bg_color Color for the header row background (default: "#ababab")
#' @param header_row_ht Height of the header row in inches
#' @param row_ht Height of regular data rows in inches
#' @param output_file Character string specifying the output file path for saving
#' @param width Total plot width in inches
#' @param height Total plot height in inches
#' @param dpi Resolution for output image (dots per inch)
#'
#' @return Table plot object that can be displayed or further customized
#'
#' @details
#' This function creates a professional table layout for abbreviation listings
#' commonly needed in supplemental materials. The table automatically handles
#' text wrapping, alignment, and formatting to ensure readability and consistency
#' with publication standards.
#'
#' @examples
#' \dontrun{
#'   # Create abbreviation data
#'   abbrev_data <- data.frame(
#'     Abbreviation = c("PGD", "ISHLT", "PCA"),
#'     Definition = c("Primary Graft Dysfunction", 
#'                   "International Society for Heart and Lung Transplantation",
#'                   "Principal Component Analysis")
#'   )
#'   
#'   # Generate table
#'   abbrev_table <- plot_S2_abbrev(
#'     table_data = abbrev_data,
#'     output_file = "supplemental_abbreviations.png"
#'   )
#' }
#'
#' @export
plot_S2_abbrev <- function(
    table_data,
    col_widths = c(1.2, 1.65, 3.575),
    header_bg_color = "#ababab",
    border_lwd = 0.75,
    font_adjustments = NULL,
    header_row_ht = 0.4,
    row_ht = 0.35,
    output_file = NULL,
    width = 6.425,
    height = 7,
    dpi = 600,
    verbose = FALSE
) {
  # ---- required libs ----
  library(ggplot2)
  library(cowplot)
  library(gridExtra)
  library(grid)
  library(gtable)
  
  # Create custom table theme with no borders
  table_theme_direct <- ttheme_minimal(
    core = list(
      fg_params = list(fontfamily = "Arial", cex = 0.4, hjust = 0, x = 0.02),
      bg_params = list(fill = "white", col = NA)
    ),
    colhead = list(
      fg_params = list(fontfamily = "Arial", fontface = "bold", cex = 0.4, hjust = 0, x = 0.02),
      bg_params = list(fill = header_bg_color, col = NA)
    )
  )

  table_grob_direct <- tableGrob(table_data, rows = NULL, theme = table_theme_direct)
  
  # Set column widths
  table_grob_direct$widths <- unit(col_widths, "in")
  
  # Set row heights
  # Header row (first row)
  table_grob_direct$heights[1] <- unit(header_row_ht, "in")
  
  # Data rows (all other rows)
  for(i in 2:length(table_grob_direct$heights)) {
    table_grob_direct$heights[i] <- unit(row_ht, "in")
  }

  # Add selective left padding to Figure.Row.Column column (column 1)
  for(i in 1:nrow(table_data)) {
    # Add padding to the first column (Figure.Row.Column)
    page_row_col_text <- table_data[i, 1]  # First column
    padded_text_grob <- grid::textGrob(
      label = page_row_col_text,
      x = 0.06, hjust = 0,  # Increased from 0.02 to 0.06 for more padding
      gp = grid::gpar(fontfamily = "Arial", cex = 0.4),
      just = "left"
    )
    
    # Find and replace the cell in column 1
    cell_indices <- which(
      grepl("core", table_grob_direct$layout$name) &
        table_grob_direct$layout$t == i + 1 &
        table_grob_direct$layout$l == 1
    )
    
    if (length(cell_indices) > 0) {
      table_grob_direct$grobs[[cell_indices[1]]] <- padded_text_grob
    }
  }
  
  # Add padding to the column header for the first column
  header_text_grob <- grid::textGrob(
    label = names(table_data)[1],  # First column name
    x = 0.06, hjust = 0,  # Same padding as data cells
    gp = grid::gpar(fontfamily = "Arial", fontface = "bold", cex = 0.4),
    just = "left"
  )
  
  # Find and replace the header cell in column 1
  header_indices <- which(
    grepl("colhead", table_grob_direct$layout$name) &
      table_grob_direct$layout$t == 1 &
      table_grob_direct$layout$l == 1
  )
  
  if (length(header_indices) > 0) {
    table_grob_direct$grobs[[header_indices[1]]] <- header_text_grob
  }

  # Selectively adjust font size for specific rows - do this BEFORE adding borders
  for(i in 1:nrow(table_data)) {
    page_row_col <- table_data[i, 1]  # First column value
    
    # Check if this row needs font adjustment
    cell_size <- font_adjustments[[as.character(page_row_col)]]
    if(is.null(cell_size)) {
      cell_size <- 0.4  # default size - updated to match universal font size
    }
    
    # Debug: print what we're trying to modify
    if(verbose && cell_size != 0.4) {
      cat("Modifying row", i, "with figure.row.col:", page_row_col, "to size:", cell_size, "\n")
    }
    
    # Update the font size for the long name column (column 3) if different from default
    if(cell_size != 0.4) {
      long_name <- table_data[i, 3]  # Third column
      text_grob <- grid::textGrob(
        label = long_name,
        x = 0.02, hjust = 0,
        gp = grid::gpar(fontfamily = "Arial", cex = cell_size),
        just = "left"
      )
      
      # Find the cell in the grob - try different approaches
      # Approach 1: Look for core cells
      cell_indices <- which(
        table_grob_direct$layout$name == "core-fg" &
          table_grob_direct$layout$t == i + 1 &
          table_grob_direct$layout$l == 3
      )
      
      if(length(cell_indices) == 0) {
        # Approach 2: Look for different naming convention
        cell_indices <- which(
          grepl("core", table_grob_direct$layout$name) &
            table_grob_direct$layout$t == i + 1 &
            table_grob_direct$layout$l == 3
        )
      }
      
      if(verbose) {
        cat("Found", length(cell_indices), "matching cells for row", i, "\n")
      }
      
      if (length(cell_indices) > 0) {
        table_grob_direct$grobs[[cell_indices[1]]] <- text_grob
        if(verbose) {
          cat("Successfully replaced cell for row", i, "\n")
        }
      } else if(verbose) {
        cat("Could not find cell for row", i, "\n")
      }
    }
  }

  # Add custom horizontal borders manually - dynamically based on number of columns
  n_cols <- ncol(table_data)
  
  # Add bottom border for header
  header_border <- grid::linesGrob(
    x = unit(c(0, 1), "npc"),
    y = unit(c(0, 0), "npc"),
    gp = grid::gpar(col = "black", lwd = border_lwd)
  )
  
  # Add borders between each row
  for(i in 1:nrow(table_data)) {
    # Add bottom border for each data row
    row_border <- grid::linesGrob(
      x = unit(c(0, 1), "npc"),
      y = unit(c(0, 0), "npc"),
      gp = grid::gpar(col = "black", lwd = border_lwd)
    )
    
    # Insert border after each row - use dynamic column count
    table_grob_direct <- gtable::gtable_add_grob(
      table_grob_direct, 
      row_border,
      t = i + 1, b = i + 1,  #+1 to account for header
      l = 1, r = n_cols,
      name = paste0("row_border_", i)
    )
  }
  
  # Add header bottom border - use dynamic column count
  table_grob_direct <- gtable::gtable_add_grob(
    table_grob_direct, 
    header_border,
    t = 1, b = 1,  # header row
    l = 1, r = n_cols,
    name = "header_border"
  )

  table_plot_direct <- ggdraw() + draw_grob(table_grob_direct)
  
  # Save the plot if output_file is provided
  if(!is.null(output_file)) {
    # Extract directory and filename parts
    output_dir <- dirname(output_file)
    filename <- basename(output_file)
    
    # Save the plot using separate dir and filename
    print_to_png(table_plot_direct, filename, width = width, height = height, dpi = dpi, output_dir = output_dir)
    
    if(verbose) {
      cat("Table saved to:", output_file, "\n")
    }
  }
  
  return(table_plot_direct)
}
