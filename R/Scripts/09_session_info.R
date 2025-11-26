#* 9: Session Information
#' Captures the exact R and package versions used for this analysis.
#' This script only runs if the entire pipeline completed successfully.
#+ 9.1: Generate and save session info
#- 9.1.1: Save to file for documentation
cat("=== Saving Session Information ===\n")
session_file <- here::here("session_info.txt")
#- 9.1.2: Capture session info with timestamp
session_output <- c(
  paste("Pipeline last run:", format(Sys.time(), "%Y-%m-%d at %H:%M:%S %Z")),
  "",
  capture.output(sessionInfo())
)
#- 9.1.3: Write to file
writeLines(session_output, session_file)
cat("✓ Session info saved to:", session_file, "\n")
cat("✓ Pipeline completed successfully!\n")
