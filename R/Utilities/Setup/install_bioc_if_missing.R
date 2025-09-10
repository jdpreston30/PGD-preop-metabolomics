#' Install missing packages from Bioconductor
#' @param packages Character vector of package names
#' @return NULL (installs packages if missing)
install_bioc_if_missing <- function(packages) {
  # ensure BiocManager is available
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  # check which packages are missing
  missing_packages <- packages[!packages %in% installed.packages()[, "Package"]]
  # install missing packages
  if (length(missing_packages) > 0) {
    cat("Installing missing Bioconductor packages:", paste(missing_packages, collapse = ", "), "\n")
    BiocManager::install(missing_packages, ask = FALSE)
  } else {
    cat("All Bioconductor packages are already installed.\n")
  }
}