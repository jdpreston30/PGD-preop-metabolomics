#' Check System Dependencies
#'
#' Checks for required system-level dependencies and provides installation
#' instructions if any are missing. This function is non-blocking and will
#' only warn users about missing dependencies.
#'
#' @details
#' This function checks for the following system dependencies:
#' - **Ghostscript**: Required for PDF to EPS conversion (pdf2ps command)
#' - **Pandoc**: Required for R Markdown rendering to PDF
#' - **ImageMagick**: Required by the magick package for image manipulation
#' - **TinyTeX/LaTeX**: Required for PDF generation from R Markdown
#'
#' @return Invisibly returns a character vector of missing dependency names.
#'   If all dependencies are found, returns an empty character vector.
#'
#' @examples
#' \dontrun{
#' # Check all system dependencies
#' check_system_dependencies()
#' }
#'
#' @author Joshua D. Preston
#' @export
check_system_dependencies <- function() {
  cat("\n🔍 Checking system dependencies...\n")
  
  # Define all system dependencies with installation instructions
  system_deps <- list(
    list(
      name = "Ghostscript",
      command = "pdf2ps",
      purpose = "PDF to EPS conversion (used in 05_render_figures.R)",
      install_mac = "brew install ghostscript",
      install_linux = "sudo apt-get install ghostscript  # or: sudo yum install ghostscript",
      install_windows = "Download from https://www.ghostscript.com/download/gsdnld.html",
      optional = FALSE
    ),
    list(
      name = "Pandoc",
      command = "pandoc",
      purpose = "R Markdown rendering (used in 08_supporting_info.R)",
      install_mac = "brew install pandoc  # or install RStudio which includes pandoc",
      install_linux = "sudo apt-get install pandoc  # or: sudo yum install pandoc",
      install_windows = "Download from https://pandoc.org/installing.html or install RStudio",
      optional = FALSE,
      check_function = function() {
        # Check if pandoc is available via rmarkdown package
        if (requireNamespace("rmarkdown", quietly = TRUE)) {
          tryCatch({
            rmarkdown::pandoc_available()
          }, error = function(e) FALSE)
        } else {
          FALSE
        }
      }
    ),
    list(
      name = "ImageMagick",
      command = "magick",
      purpose = "Image processing via magick package (used in 04_assign_plots.R, 05_render_figures.R)",
      install_mac = "brew install imagemagick",
      install_linux = "sudo apt-get install imagemagick  # or: sudo yum install ImageMagick",
      install_windows = "Download from https://imagemagick.org/script/download.php",
      optional = FALSE,
      check_function = function() {
        # ImageMagick can be available via R's magick package without system install
        if (requireNamespace("magick", quietly = TRUE)) {
          tryCatch({
            magick::magick_config()
            TRUE
          }, error = function(e) FALSE)
        } else {
          FALSE
        }
      }
    ),
    list(
      name = "TinyTeX/LaTeX",
      command = "pdflatex",
      purpose = "LaTeX compilation for R Markdown PDF output (used in 08_supporting_info.R)",
      install_mac = "Install via R: tinytex::install_tinytex()",
      install_linux = "Install via R: tinytex::install_tinytex()  # or: sudo apt-get install texlive-full",
      install_windows = "Install via R: tinytex::install_tinytex()",
      optional = FALSE,
      check_function = function() {
        # Check if TinyTeX is installed via tinytex package
        if (requireNamespace("tinytex", quietly = TRUE)) {
          tinytex::is_tinytex()
        } else {
          FALSE
        }
      }
    )
  )
  
  missing_deps <- character(0)
  
  # Check each dependency
  for (dep in system_deps) {
    is_available <- FALSE
    
    # Use custom check function if provided, otherwise check command
    if (!is.null(dep$check_function)) {
      is_available <- dep$check_function()
    } else {
      is_available <- Sys.which(dep$command) != ""
    }
    
    if (!is_available) {
      missing_deps <- c(missing_deps, dep$name)
      cat("⚠️  ", dep$name, " not found\n", sep = "")
      cat("   Purpose: ", dep$purpose, "\n", sep = "")
      cat("   Install:\n")
      cat("     macOS:   ", dep$install_mac, "\n", sep = "")
      cat("     Linux:   ", dep$install_linux, "\n", sep = "")
      cat("     Windows: ", dep$install_windows, "\n", sep = "")
      cat("\n")
    } else {
      cat("✓ ", dep$name, " found\n", sep = "")
    }
  }
  
  # Summary message
  if (length(missing_deps) > 0) {
    cat("⚠️  Warning: ", length(missing_deps), " system dependency(ies) missing: ", 
        paste(missing_deps, collapse = ", "), "\n", sep = "")
    cat("   Some functionality may be unavailable until installed.\n")
    cat("   You can continue, but certain scripts may fail without these dependencies.\n\n")
  } else {
    cat("✅ All system dependencies found!\n\n")
  }
  
  invisible(missing_deps)
}
