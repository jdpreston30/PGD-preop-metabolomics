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
#+ 0a.2: Check system dependencies
source("R/Utilities/Helpers/check_system_dependencies.R")
check_system_dependencies()