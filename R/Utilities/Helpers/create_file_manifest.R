#' Get Actual File Names from Archives
#'
#' Extracts the actual file names from 7z archives without extracting the files
#'
#' @param archive_paths Named list of paths to archive files
#'
#' @return A tibble with actual file names from each archive
#'
#' @examples
#' \dontrun{
#' archives <- list(c18neg = "/path/to/c18neg.7z", hilicpos = "/path/to/hilicpos.7z")
#' manifest <- get_archive_file_names(archives)
#' }
#'
#' @export
get_archive_file_names <- function(archive_paths) {
  
  # Function to list contents of one archive
  list_archive_contents <- function(zip_path, type_name) {
    cat("Processing:", type_name, "at", zip_path, "\n")
    
    if (!file.exists(zip_path)) {
      cat("File does not exist:", zip_path, "\n")
      return(tibble::tibble(
        archive_type = type_name,
        filename = character(0),
        full_path = zip_path
      ))
    }
    
    # Try using R's archive package
    if (requireNamespace("archive", quietly = TRUE)) {
      tryCatch({
        files <- archive::archive(zip_path)
        cat("Found", nrow(files), "files in", type_name, "\n")
        if (nrow(files) > 0) {
          return(tibble::tibble(
            archive_type = type_name,
            filename = basename(files$path),
            full_path = zip_path,
            file_size = files$size
          ))
        }
      }, error = function(e) {
        cat("Archive package failed for", type_name, ":", e$message, "\n")
      })
    }
    
    # If archive package fails, return empty
    cat("Could not read contents of", type_name, "archive\n")
    return(tibble::tibble(
      archive_type = type_name,
      filename = character(0),
      full_path = zip_path,
      file_size = numeric(0)
    ))
  }
  
  # Process all archives
  result <- purrr::map2_dfr(archive_paths, names(archive_paths), list_archive_contents)
  return(result)
}