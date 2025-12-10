#* 8: Generate Supporting Information PDF
#' Orchestrates creation of complete supporting information PDF document.
#' Combines modular components from Supporting Information/Components folder
#' (cover page, figures, methods sections). Checks TinyTeX installation.
#' Renders final PDF with proper LaTeX formatting and references.
#+ 8.0: Setup and Dependencies
#- 8.0.1: Check TinyTeX installation
if (!tinytex::is_tinytex()) {
  message("TinyTeX not found. Installing...")
  tinytex::install_tinytex()
}
#- 8.0.2: Assumes figure objects are already loaded in environment
# Run your full pipeline first in R terminal to create:
# sup_fig1, S2.1, S2.2, S2.3, S2.4, S2.5, add_s2_footnote function
#+ 8.1: Read Component Files
#- 8.1.1: Define paths to all component files
components_dir <- here::here("Supporting Information", "Components")
sections_dir <- file.path(components_dir, "Sections")
cover_page_path <- file.path(sections_dir, "cover_page.Rmd")
figures_path <- file.path(sections_dir, "figures.Rmd")
methods_path <- file.path(sections_dir, "methods.tex")
#- 8.1.2: Check that all components exist
required_files <- c(cover_page_path, figures_path, methods_path)
missing_files <- required_files[!file.exists(required_files)]
if (length(missing_files) > 0) {
  stop("Missing component files: ", paste(missing_files, collapse = ", "))
}
#+ 8.2: Combine Components
#- 8.2.1: Read each component
cover_content <- readLines(cover_page_path, warn = FALSE)
figures_content <- readLines(figures_path, warn = FALSE)
methods_content <- readLines(methods_path, warn = FALSE)
#- 8.2.2: Fix paths for rendering from Supporting Information directory (not Components)
# Since we write supporting_info.Rmd to Supporting Information/, paths need to be relative from there
bib_path_rel <- file.path("Components", "References", "Supporting_AJT.bib")
csl_path_rel <- file.path("Components", "References", "jama.csl")
# Replace the relative paths in cover content - handle both "../References/" and "References/"
cover_content <- gsub('"../References/Supporting_AJT.bib"', paste0('"', bib_path_rel, '"'), cover_content, fixed = TRUE)
cover_content <- gsub('"References/Supporting_AJT.bib"', paste0('"', bib_path_rel, '"'), cover_content, fixed = TRUE)
cover_content <- gsub('"../References/jama.csl"', paste0('"', csl_path_rel, '"'), cover_content, fixed = TRUE)
cover_content <- gsub('"References/jama.csl"', paste0('"', csl_path_rel, '"'), cover_content, fixed = TRUE)
# Fix figure paths to be relative from Supporting Information directory
figures_content <- gsub('../Figures/PDF/', 'Components/Figures/PDF/', figures_content, fixed = TRUE)
#- 8.2.3: Combine all content
full_content <- c(
  cover_content,
  "",  # Empty line for separation
  figures_content,
  "",  # Empty line for separation
  methods_content
)
#+ 8.3: Generate Final PDF
#- 8.3.1: Write combined markdown file
output_dir <- here::here("Supporting Information")
output_rmd <- file.path(output_dir, "supporting_info.Rmd")
writeLines(full_content, output_rmd)
#- 8.3.2: Render to PDF in Supporting Information directory
rmarkdown::render(
  input = output_rmd,
  output_dir = output_dir,
  output_file = "Supporting Information.pdf",
  clean = FALSE  # Keep intermediates so we can control cleanup
)
#+ 8.4: Clean up intermediate files
#- 8.4.1: Remove .log, .tex, and intermediate .md files, keep only .Rmd and .pdf
cat("\n🧹 Cleaning up intermediate files...\n")
# List all files before cleanup
all_files <- list.files(output_dir, full.names = FALSE)
cat("Files in directory:", paste(all_files, collapse = ", "), "\n")
intermediate_patterns <- c(
  "Supporting Information.log",
  "Supporting Information.tex",
  "supporting_info.knit.md",
  "supporting_info.utf8.md"
)
files_removed <- 0
for (pattern in intermediate_patterns) {
  file <- file.path(output_dir, pattern)
  cat("Checking:", pattern, "... ")
  if (file.exists(file)) {
    cat("exists, removing... ")
    result <- file.remove(file)
    if (result) {
      cat("✓ removed\n")
      files_removed <- files_removed + 1
    } else {
      cat("✗ FAILED\n")
      warning("Failed to remove: ", pattern)
    }
  } else {
    cat("not found\n")
  }
}
cat("\n✅ Supporting Information PDF generated and cleaned (", files_removed, " files removed)\n", sep = "")