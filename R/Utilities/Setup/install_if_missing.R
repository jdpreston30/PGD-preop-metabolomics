#' Install missing packages from CRAN
#' @param packages Character vector of package names
#' @return NULL (installs packages if missing)
install_if_missing <- function(packages) {
  # check which packages are missing
  missing_packages <- packages[!packages %in% installed.packages()[,"Package"]]
  # install missing packages
  if(length(missing_packages) > 0) {
    cat("Installing missing CRAN packages:", paste(missing_packages, collapse = ", "), "\n")
    install.packages(missing_packages, dependencies = TRUE)
  } else {
    cat("All CRAN packages are already installed.\n")
  }
}

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

#' Install missing packages from Bioconductor
#' @param packages Character vector of package names
#' @return NULL (installs packages if missing)
install_bioc_if_missing <- function(packages) {
  # ensure BiocManager is available
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  # check which packages are missing
  missing_packages <- packages[!packages %in% installed.packages()[,"Package"]]
  # install missing packages
  if(length(missing_packages) > 0) {
    cat("Installing missing Bioconductor packages:", paste(missing_packages, collapse = ", "), "\n")
    BiocManager::install(missing_packages, ask = FALSE)
  } else {
    cat("All Bioconductor packages are already installed.\n")
  }
}

#' Install GitHub packages if missing
#' @param github_info List with repo and package name
#' @param force_reinstall Logical, whether to force reinstall
#' @return NULL (installs package if missing)
install_github_if_missing <- function(github_info, force_reinstall = FALSE) {
  # check if github package is missing
  package_name <- github_info$package
  github_repo <- github_info$repo
  
  if(!package_name %in% installed.packages()[,"Package"] || force_reinstall) {
    cat("Installing", package_name, "from GitHub...\n")
    remotes::install_github(github_repo, force = force_reinstall)
  } else {
    cat(package_name, "is already installed.\n")
  }
}
