#! ORIGINAL EXCEL FORMULA
# =IF(Q41="Female", (6.82 * (R41/100)^0.54 * S41^0.61) + (10.59 * O41^-0.32 * (R41/100)^1.135 * S41^0.315), (8.25 * (R41/100)^0.54 * S41^0.61) + (11.25 * O41^-0.32 * (R41/100)^1.135 * S41^0.315))
calc_PHM <- function(clinical_metadata, 
                     donor_age_col = "donor_age",
                     donor_sex_col = "donor_sex",
                     donor_weight_col = "donor_weight",
                     donor_height_col = "donor_height") {

  clinical_metadata <- clinical_metadata %>%
    mutate(
      donor_PHM = case_when(
        .data[[donor_sex_col]] == "Female" ~ (6.82 * (.data[[donor_height_col]] / 100)^0.54 * .data[[donor_weight_col]]^0.61) + (10.59 * .data[[donor_age_col]]^-0.32 * (.data[[donor_height_col]] / 100)^1.135 * .data[[donor_weight_col]]^0.315),
        TRUE ~ (8.25 * (.data[[donor_height_col]] / 100)^0.54 * .data[[donor_weight_col]]^0.61) + (11.25 * .data[[donor_age_col]]^-0.32 * (.data[[donor_height_col]] / 100)^1.135 * .data[[donor_weight_col]]^0.315)
      )
    }

  return(clinical_metadata)
}


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