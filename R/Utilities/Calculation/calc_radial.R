calc_radial <- function(clinical_data, 
                        rap_col, 
                        age_col, 
                        dm_col, 
                        inotrope_col, 
                        donor_age_col, 
                        ischemic_time_col) {
  # Check for missing values in required columns
  required_cols <- c(rap_col, age_col, dm_col, inotrope_col, donor_age_col, ischemic_time_col)
  col_names <- c("RAP", "Age", "Diabetes", "Inotrope", "Donor Age", "Ischemic Time")
  
  for (i in seq_along(required_cols)) {
    col <- required_cols[i]
    na_count <- sum(is.na(clinical_data[[col]]))
    if (na_count > 0) {
      warning(paste0("Missing values detected: ", na_count, " NA(s) in ", col_names[i], 
                     " column (", col, "). Radial score calculation may be incomplete for affected patients."))
    }
  }
  
  clinical_data %>%
    mutate(
      radial_calc = rowSums(
        cbind(
          !!sym(rap_col) >= 10, # Recipient right atrial pressure ≥ 10 mmHg
          !!sym(age_col) >= 60, # Recipient age ≥ 60 years
          !!sym(dm_col) == "Yes", # Recipient diabetes mellitus
          !!sym(inotrope_col) == "Yes", # Recipient inotrope dependence
          !!sym(donor_age_col) >= 30, # Donor age ≥ 30 years
          !!sym(ischemic_time_col) >= 240 # Ischemic time ≥ 240 minutes
        ),
        na.rm = TRUE # Ignore NA values in row-wise summation
      )
    )
}
        # radial <- clinical_data_raw %>%
        #   mutate(
        #     radial_calc = rowSums(
        #       cbind(
        #         preop_RAP >= 10, # Recipient right atrial pressure ≥ 10 mmHg
        #         demographics_age_tpx >= 60, # Recipient age ≥ 60 years
        #         comorbidities_DM == "Yes", # Recipient diabetes mellitus
        #         rx_preop_inotrope == "Yes", # Recipient inotrope dependence
        #         donor_age >= 30, # Donor age ≥ 30 years (from table2_raw)
        #         operative_IT_minutes >= 240 # Ischemic time ≥ 240 minutes (from table3_raw)
        #       ),
        #       na.rm = TRUE # Ignore NA values in row-wise summation
        #     )
        #   ) %>%
        #   select(Patient, radial_calc)