#' Load packages safely with error handling and memory management
#' @param packages Character vector of package names
#' @param package_type Character, type of packages ("CRAN", "Bioconductor", etc.)
#' @return NULL (loads packages)
load_packages_safely <- function(packages, package_type = "CRAN") {
  cat("Loading", package_type, "packages...\n")
  for (pkg in packages) {
    tryCatch({
      # Force garbage collection before loading each package
      if (pkg %in% c("mixOmics", "data.table", "MetaboJanitoR")) {
        gc(verbose = FALSE)
      }
      library(pkg, character.only = TRUE, quietly = TRUE)
      cat("✓", pkg, "\n")
    }, error = function(e) {
      cat("✗ Failed to load", pkg, ":", e$message, "\n")
    })
  }
}
