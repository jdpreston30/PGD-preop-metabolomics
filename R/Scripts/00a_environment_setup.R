#* 0a: Environment Setup
#' Package management is handled by renv for reproducibility.
#' All required packages and their exact versions are specified in renv.lock.
#' 
#' This script automatically checks for missing packages and runs renv::restore()
#' if needed, making the pipeline self-sufficient for first-time setup.
#' 
#' The .Rprofile automatically activates the renv environment when R starts.

#+ 0a.1: Verify renv is active
cat("📦 Package environment managed by renv\n")
if (!("renv" %in% loadedNamespaces())) {
  warning("⚠️  renv is not active. Attempting to activate...")
  source("renv/activate.R")
}
#+ 0a.2: Check if packages need to be installed
core_packages <- c("dplyr", "ggplot2", "here", "purrr", "yaml")
missing_core <- core_packages[!sapply(core_packages, requireNamespace, quietly = TRUE)]
if (length(missing_core) > 0) {
  cat("⚠️  Core packages missing:", paste(missing_core, collapse = ", "), "\n")
  cat("🔄 Running renv::restore() to install packages...\n")
  cat("   (This may take 10-20 minutes on first run)\n\n")
  # Run renv::restore() automatically
  tryCatch({
    renv::restore(prompt = FALSE)  # No prompt, automatic yes
    cat("\n✅ Package installation complete!\n")
  }, error = function(e) {
    stop("❌ Failed to restore packages: ", e$message, 
         "\n   Please run renv::restore() manually and check for errors.")
  })
  # Verify installation succeeded
  still_missing <- core_packages[!sapply(core_packages, requireNamespace, quietly = TRUE)]
  if (length(still_missing) > 0) {
    stop("❌ Packages still missing after restore: ", paste(still_missing, collapse = ", "),
         "\n   Please check renv::status() for details.")
  }
} else {
  cat("✅ renv environment verified. All core packages available.\n")
}
#+ 0a.3: Load conflicted and set ALL preferences BEFORE loading other packages
library(conflicted)
# Set all conflict preferences to prevent warnings during package loading
conflicts_prefer(purrr::map)
conflicts_prefer(dplyr::filter)
conflicts_prefer(dplyr::summarize)
conflicts_prefer(dplyr::select)
conflicts_prefer(dplyr::first)
conflicts_prefer(dplyr::mutate)
conflicts_prefer(dplyr::arrange)
conflicts_prefer(dplyr::summarise)
conflicts_prefer(dplyr::count)
conflicts_prefer(dplyr::rename)
conflicts_prefer(ggplot2::margin)
conflicts_prefer(stats::chisq.test)
conflicts_prefer(stats::fisher.test)
conflicts_prefer(jsonlite::fromJSON)
conflicts_prefer(readxl::read_xlsx)
conflicts_prefer(raster::intersect)
conflicts_prefer(igraph::compose)
conflicts_prefer(flextable::align)
conflicts_prefer(base::setdiff)
conflicts_prefer(base::as.factor)
conflicts_prefer(base::unique)
conflicts_prefer(base::as.data.frame)
#+ 0a.4: Load all packages from DESCRIPTION file
source("R/Utilities/Helpers/load_packages_from_description.R")
load_packages_from_description()
#+ 0a.5: Load GitHub Packages explicitly for renv detection
library(TernTablesR)
library(MetaboAnalystR)
#+ 0a.6: Check system dependencies
source("R/Utilities/Helpers/check_system_dependencies.R")
check_system_dependencies()