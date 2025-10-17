#* 9: Supporting Information Construction
#+ 9.0: Compile Supplementals into a single PDF
#- 9.0.1: Create vector in order
supplemental_png_files <- c(
  "Outputs/Figures/Final/S1.png",
  "Outputs/Figures/Final/S2.1.png",
  "Outputs/Figures/Final/S2.2.png",
  "Outputs/Figures/Final/S2.3.png",
  "Outputs/Figures/Final/S2.4.png",
  "Outputs/Figures/Final/S2.5.png"
)
#- 9.0.2: Read individual pngs in
img_collection <- image_read(supplemental_png_files[1])
for (i in 2:length(supplemental_png_files)) {
  img_collection <- c(img_collection, image_read(supplemental_png_files[i]))
}
image_write(img_collection, "Supporting Information/Components/Supplemental_Figures.pdf", format = "pdf")

#+ 9.1: Simple PDF combination workflow
library(magick)

# Define paths
components_dir <- "Supporting Information/Components"
cover_docx <- file.path(components_dir, "Supporting Material Cover.docx")
methods_docx <- file.path(components_dir, "Supplemental_Methods.docx")
figures_pdf <- file.path(components_dir, "Supplemental_Figures.pdf")

output_dir <- "Supporting Information"
final_pdf <- file.path(output_dir, "Supporting Information.pdf")

cat("Starting PDF combination workflow...\n")

# Step 1: Convert cover to PDF using AppleScript (macOS)
cat("1. Converting cover to PDF using AppleScript...\n")
cover_pdf <- file.path(components_dir, "Supporting Material Cover.pdf")

tryCatch({
  # Use AppleScript to automate Microsoft Word
  cover_path_full <- normalizePath(cover_docx)
  pdf_path_full <- normalizePath(file.path(components_dir, "Supporting Material Cover.pdf"), mustWork = FALSE)
  
  applescript <- paste0('
    tell application "Microsoft Word"
      open POSIX file "', cover_path_full, '"
      set myDoc to active document
      save as myDoc file name "', pdf_path_full, '" file format format PDF
      close myDoc saving no
    end tell
  ')
  
  system(paste("osascript -e", shQuote(applescript)))
  
  if (!file.exists(cover_pdf)) {
    stop("PDF conversion failed")
  }
}, error = function(e) {
  cat("Automatic conversion failed. Please manually convert:\n")
  cat("1. Open", cover_docx, "in Word\n")
  cat("2. File → Export → Create PDF/XPS\n") 
  cat("3. Save as 'Supporting Material Cover.pdf' in Components folder\n")
  stop("Cover PDF not found. Please convert manually and re-run.")
})

# Step 2: Convert methods to PDF using AppleScript
cat("2. Converting methods to PDF using AppleScript...\n")
methods_pdf <- file.path(components_dir, "Supplemental_Methods.pdf")

tryCatch({
  methods_path_full <- normalizePath(methods_docx)
  methods_pdf_full <- normalizePath(file.path(components_dir, "Supplemental_Methods.pdf"), mustWork = FALSE)
  
  applescript <- paste0('
    tell application "Microsoft Word"
      open POSIX file "', methods_path_full, '"
      set myDoc to active document
      save as myDoc file name "', methods_pdf_full, '" file format format PDF
      close myDoc saving no
    end tell
  ')
  
  system(paste("osascript -e", shQuote(applescript)))
  
  if (!file.exists(methods_pdf)) {
    stop("PDF conversion failed")
  }
}, error = function(e) {
  cat("Automatic conversion failed. Please manually convert:\n")
  cat("1. Open", methods_docx, "in Word\n")
  cat("2. File → Export → Create PDF/XPS\n")
  cat("3. Save as 'Supplemental_Methods.pdf' in Components folder\n")
  stop("Methods PDF not found. Please convert manually and re-run.")
})

# Step 3: Combine all PDFs using magick
cat("3. Combining PDFs (cover + methods + figures)...\n")

# Check if all files exist before combining
if (!file.exists(cover_pdf)) {
  stop("Cover PDF not found: ", cover_pdf)
}
if (!file.exists(methods_pdf)) {
  stop("Methods PDF not found: ", methods_pdf)
}
if (!file.exists(figures_pdf)) {
  stop("Figures PDF not found: ", figures_pdf)
}

# Read all PDFs as images
cat("Reading PDF files...\n")
cover_img <- image_read_pdf(cover_pdf)
methods_img <- image_read_pdf(methods_pdf)
figures_img <- image_read_pdf(figures_pdf)

# Combine all images
cat("Combining pages...\n")
all_pages <- c(cover_img, methods_img, figures_img)

# Write final combined PDF (page numbers already included in individual PDFs)
cat("Creating final Supporting Information.pdf...\n")
image_write(all_pages, final_pdf, format = "pdf")

# Clean up - no temp files needed
cat("\n")
cat(strrep("=", 60), "\n")
cat("SUPPORTING INFORMATION COMPLETE\n")
cat(strrep("=", 60), "\n")
cat("Final PDF created:", final_pdf, "\n")
cat("✓ Cover page (from Supporting Material Cover.pdf)\n")
cat("✓ Methods (from Supplemental_Methods.pdf)\n")
cat("✓ Figures (from Supplemental_Figures.pdf)\n")
cat("✓ All page numbers already included in individual PDFs\n")
cat("Total pages:", length(all_pages), "\n")