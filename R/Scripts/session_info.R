#' Session Information
#' 
#' This file captures the exact R and package versions used for this analysis.
#' Run this script to generate session info for reproducibility documentation.

#' Generate session info
cat("=== R Session Information ===\n")
cat("Analysis conducted on:", format(Sys.time()), "\n\n")

# Print R version and platform info
print(sessionInfo())

# Save to file for documentation
session_file <- here::here("session_info.txt")
writeLines(capture.output(sessionInfo()), session_file)
cat("\n📄 Session info saved to:", session_file, "\n")

# Print package versions in a clean format
cat("\n=== Key Package Versions ===\n")

# Read packages from DESCRIPTION file
desc_file <- here::here("DESCRIPTION")
desc_lines <- readLines(desc_file)
imports_start <- which(grepl("^Imports:", desc_lines))
next_field <- which(grepl("^[A-Z]", desc_lines[(imports_start + 1):length(desc_lines)]))
if (length(next_field) > 0) {
  imports_end <- imports_start + next_field[1] - 1
} else {
  imports_end <- length(desc_lines)
}
imports_lines <- desc_lines[imports_start:imports_end]
imports_text <- paste(imports_lines, collapse = " ")
imports_text <- gsub("Imports:", "", imports_text)
imports_text <- gsub("\\s+", " ", imports_text)
packages <- strsplit(imports_text, ",")[[1]]
required_packages <- trimws(packages)
required_packages <- required_packages[required_packages != ""]

for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    version <- as.character(packageVersion(pkg))
    cat(sprintf("%-15s %s\n", pkg, version))
  }
}