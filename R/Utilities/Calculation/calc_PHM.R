#! ORIGINAL FORMULA
# =IF(Q41="Female", (6.82 * (R41/100)^0.54 * S41^0.61) + (10.59 * O41^-0.32 * (R41/100)^1.135 * S41^0.315), (8.25 * (R41/100)^0.54 * S41^0.61) + (11.25 * O41^-0.32 * (R41/100)^1.135 * S41^0.315))

#! ORIGINAL COLUMNS
# donor_age = O
# donor_sex = Q
# donor_weight = S
# donor_height = R

#! REFERENCE COLUMN TO COMPARE
# donor_PHM

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
}