#' Load All Packages from DESCRIPTION File
#'
#' Reads the DESCRIPTION file and loads all packages listed in the Imports
#' and Bioconductor sections. This centralizes package loading and ensures
#' all dependencies are available for the analysis pipeline.
#'
#' @param desc_file Path to DESCRIPTION file. Default is "DESCRIPTION" in project root.
#' @param verbose Logical. Print loading progress? Default TRUE.
#' @return Invisible vector of loaded package names
#' @export
load_packages_from_description <- function(desc_file = "DESCRIPTION", verbose = TRUE) {
  
  if (!file.exists(desc_file)) {
    warning("DESCRIPTION file not found at: ", desc_file)
    return(invisible(character(0)))
  }
  
  desc_lines <- readLines(desc_file)
  
  # Function to extract packages from a section
  extract_packages <- function(section_name) {
    section_start <- which(grepl(paste0("^", section_name, ":"), desc_lines))
    if (length(section_start) == 0) return(character(0))
    
    # Find end of section (next field starting with capital letter)
    next_field <- which(grepl("^[A-Z]", desc_lines[(section_start + 1):length(desc_lines)]))
    section_end <- if (length(next_field) > 0) {
      section_start + next_field[1] - 1
    } else {
      length(desc_lines)
    }
    
    # Extract and parse package names
    section_lines <- desc_lines[section_start:section_end]
    section_text <- paste(section_lines, collapse = " ")
    section_text <- gsub(paste0(section_name, ":"), "", section_text)
    section_text <- gsub("\\s+", " ", section_text)
    packages <- strsplit(section_text, ",")[[1]]
    packages <- trimws(packages)
    packages <- packages[packages != ""]
    return(packages)
  }
  
  # Get packages from Imports, Bioconductor, and Remotes sections
  imports_packages <- extract_packages("Imports")
  bioc_packages <- extract_packages("Bioconductor")
  
  # Extract GitHub package names from Remotes (format: user/repo)
  remotes_packages <- extract_packages("Remotes")
  remotes_packages <- sapply(remotes_packages, function(x) {
    # Extract package name from user/repo format
    parts <- strsplit(x, "/")[[1]]
    if (length(parts) == 2) parts[2] else x
  })
  
  all_packages <- c(imports_packages, bioc_packages, remotes_packages)
  
  if (length(all_packages) == 0) {
    if (verbose) cat("ℹ️  No packages found in DESCRIPTION\n")
    return(invisible(character(0)))
  }
  
  # Load all packages
  if (verbose) cat("📚 Loading packages from DESCRIPTION...\n")
  
  # Track which packages loaded successfully
  loaded <- character(0)
  failed <- character(0)
  
  # Suppress both startup messages and conflict warnings
  suppressPackageStartupMessages({
    suppressMessages({
      for (pkg in all_packages) {
        result <- tryCatch({
          library(pkg, character.only = TRUE, quietly = TRUE)
          loaded <- c(loaded, pkg)
          TRUE
        }, error = function(e) {
          failed <- c(failed, pkg)
          FALSE
        })
      }
    })
  })
  
  if (verbose) {
    if (length(failed) > 0) {
      cat("⚠️ ", length(loaded), "packages loaded,", length(failed), "failed:\n")
      cat("   Failed:", paste(failed, collapse = ", "), "\n")
    } else {
      cat("✅ All", length(loaded), "packages loaded!\n")
    }
  }
  
  invisible(list(loaded = loaded, failed = failed))
}
