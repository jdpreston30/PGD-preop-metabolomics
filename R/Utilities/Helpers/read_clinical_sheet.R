read_clinical_sheet <- function(sheet_name, suppress_warnings = FALSE) {
  read_fn <- if (suppress_warnings) {
    function(...) suppressWarnings(read_xlsx(...))
  } else {
    read_xlsx
  }
  
  read_fn(
    config$paths$clinical_metadata, 
    sheet = sheet_name, 
    na = c("", "NA", "-")
  ) %>%
    filter(Patient %in% analyzed_patients)
}
