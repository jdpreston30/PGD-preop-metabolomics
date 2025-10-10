#' List Directory Structure as Tree
#'
#' Recursively prints the directory structure in a tree-like format using
#' Unicode box-drawing characters, similar to the Unix `tree` command.
#'
#' @param path Character string specifying the root directory path (default: current directory)
#' @param prefix Character string for internal use in recursion (default: "")
#'
#' @return None (invisible NULL). Function is called for its side effect of printing to console.
#'
#' @details
#' The function uses Unicode characters to create a visual tree structure:
#' - ├── for items with siblings below
#' - └── for the last item in a directory
#' - │   for vertical continuation lines
#' - "    " for spacing in completed branches
#'
#' @examples
#' \dontrun{
#'   # Print tree structure of current directory
#'   list_tree()
#'   
#'   # Print tree structure of specific directory
#'   list_tree("R/Utilities")
#' }
#'
#' @export
list_tree <- function(path = ".", prefix = "") {
  items <- list.files(path, full.names = TRUE)
  for (i in seq_along(items)) {
    item <- items[i]
    name <- basename(item)
    cat(prefix, if (i == length(items)) "└── " else "├── ", name, "\n", sep = "")
    if (dir.exists(item)) {
      list_tree(item, paste0(prefix, if (i == length(items)) "    " else "│   "))
    }
  }
}
