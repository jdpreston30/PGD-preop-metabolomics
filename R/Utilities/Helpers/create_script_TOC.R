create_script_TOC <- function(output_file = "R/Scripts/TOC.txt") {
  #' Create Table of Contents for Analysis Scripts
  #' 
  #' Extracts all section headers (#*, #+, #-) from numbered analysis scripts
  #' (00a through 09) and writes them to a text file in order.
  #' 
  #' @param output_file Path to output file (default: "R/Scripts/TOC.txt")
  #' @return Invisibly returns the TOC content as a character vector
  #' @examples
  #' create_script_TOC()
  #' create_script_TOC("Outputs/Other/script_toc.txt")
  
  # Define script files in order
  script_files <- c(
    "R/Scripts/00a_environment_setup.R",
    "R/Scripts/00b_setup.R",
    "R/Scripts/00c_clinical_metadata.R",
    "R/Scripts/00d_FTs.R",
    "R/Scripts/01_clustering.R",
    "R/Scripts/02_pathway_enrich.R",
    "R/Scripts/03_annotated_bars.R",
    "R/Scripts/04_assign_plots.R",
    "R/Scripts/05_render_figures.R",
    "R/Scripts/06_tables.R",
    "R/Scripts/07_data_not_shown.R",
    "R/Scripts/08_supporting_info.R",
    "R/Scripts/09_session_info.R"
  )
  
  # Initialize vector to store TOC lines
  toc_lines <- c()
  
  # Process each script file
  for (script_file in script_files) {
    if (!file.exists(script_file)) {
      warning(paste("Script file not found:", script_file))
      next
    }
    
    # Read the file
    file_lines <- readLines(script_file, warn = FALSE)
    
    # Extract lines that start with #*, #+, or #-
    section_lines <- grep("^#[*+-] ", file_lines, value = TRUE)
    
    if (length(section_lines) > 0) {
      # Add a header with the script filename
      toc_lines <- c(toc_lines, "", paste0("=== ", basename(script_file), " ==="), section_lines)
    }
  }
  
  # Remove leading empty line if present
  if (length(toc_lines) > 0 && toc_lines[1] == "") {
    toc_lines <- toc_lines[-1]
  }
  
  # Create output directory if it doesn't exist
  output_dir <- dirname(output_file)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Write to file
  writeLines(toc_lines, output_file)
  
  message(paste("Table of Contents written to:", output_file))
  message(paste("Total sections found:", length(grep("^#[*+-]", toc_lines))))
  
  invisible(toc_lines)
}
