calc_radial <- function(clinical_metadata, 
                        rap_col, 
                        age_col, 
                        dm_col, 
                        inotrope_col, 
                        donor_age_col, 
                        ischemic_time_col) {
  # Check for missing values in required columns
  required_cols <- c(rap_col, age_col, dm_col, inotrope_col, donor_age_col, ischemic_time_col)
  col_names <- c("RAP", "Age", "Diabetes", "Inotrope", "Donor Age", "Ischemic Time")
  
  # Track missing data details
  missing_data_found <- FALSE
  
  for (i in seq_along(required_cols)) {
    col <- required_cols[i]
    na_indices <- which(is.na(clinical_metadata[[col]]))
    na_count <- length(na_indices)
    
    if (na_count > 0) {
      missing_data_found <- TRUE
      affected_patients <- clinical_metadata$Patient[na_indices]
      
      cat("\n=== MISSING DATA ALERT ===\n")
      cat("Column:", col_names[i], "(", col, ")\n")
      cat("Missing values:", na_count, "\n")
      cat("Affected patients:", paste(affected_patients, collapse = ", "), "\n")
      cat("========================\n")
      
      warning(paste0("Missing values detected: ", na_count, " NA(s) in ", col_names[i], 
                     " column (", col, "). Radial score calculation may be incomplete for affected patients."))
    }
  }
  
  # Summary of all missing data
  if (missing_data_found) {
    # Create a matrix to check for missing values across all required columns
    missing_matrix <- is.na(clinical_metadata[required_cols])
    
    # Calculate missing count and identify missing columns for each patient
    missing_summary <- data.frame(
      Patient = clinical_metadata$Patient,
      missing_count = rowSums(missing_matrix),
      stringsAsFactors = FALSE
    )
    
    # Add missing column names for each patient
    missing_summary$missing_columns <- apply(missing_matrix, 1, function(row) {
      if (sum(row) > 0) {
        paste(col_names[which(row)], collapse = ", ")
      } else {
        ""
      }
    })
    
    # Filter to only patients with missing data
    missing_summary <- missing_summary[missing_summary$missing_count > 0, ]
    
    cat("\n=== PATIENT-LEVEL MISSING DATA SUMMARY ===\n")
    print(missing_summary)
    cat("==========================================\n\n")
  }
  
  # Calculate RADIAL score
  clinical_metadata_with_radial <- clinical_metadata %>%
    mutate(
      preop_RADIAL_calc = ifelse(
        # Check if ANY required values are missing for this patient
        is.na(.data[[rap_col]]) | 
        is.na(.data[[age_col]]) | 
        is.na(.data[[dm_col]]) | 
        is.na(.data[[inotrope_col]]) | 
        is.na(.data[[donor_age_col]]) | 
        is.na(.data[[ischemic_time_col]]),
        NA,  # Return NA if any values are missing
        # Otherwise calculate the RADIAL score
        rowSums(
          cbind(
            .data[[rap_col]] >= 10,      # RAP ≥ 10 mmHg
            .data[[age_col]] >= 60,      # Age ≥ 60 years
            .data[[dm_col]] %in% c("Y", "Yes", "YES"), # Diabetes = Yes
            .data[[inotrope_col]] %in% c("Y", "Yes", "YES"), # Inotrope = Yes
            .data[[donor_age_col]] >= 30, # Donor age ≥ 30 years
            .data[[ischemic_time_col]] >= 240 # Ischemic time ≥ 240 min
          )
        )
      )
    )
  
  cat("RADIAL scores calculated successfully!\n")
  cat("RADIAL score range:", min(clinical_metadata_with_radial$preop_RADIAL_calc, na.rm = TRUE), 
      "to", max(clinical_metadata_with_radial$preop_RADIAL_calc, na.rm = TRUE), "\n\n")
  
  return(clinical_metadata_with_radial)
}
