#! INPUTS
# column names for varaiables, tibble to add columns to
calc_PGD <- function(clinical_data,
postop_MCS_Impella5.5_DEPENDENT_col = "postop_MCS_Impella5.5_DEPENDENT",
                     postop_MCS_Impella5.5_col = "postop_MCS_Impella5.5",
                     postop_MCS_RVAD_col = "postop_MCS_RVAD",
                     postop_MCS_IABP_col = "postop_MCS_IABP",
                     postop_VA_ECMO_col = "postop_VA_ECMO",
                     postop_CVP_col = "postop_CVP",
                     postop_cardiac_index_col = "postop_cardiac_index",
                     postop_LVEF_median_col = "postop_LVEF_median",
                     postop_inotrope_score_col = "postop_inotrope_score") 
                     
                     {
  clinical_data %>%
    mutate(
      ISHLT_PGD_grade = case_when(
        # Check for missing data in all relevant columns
        is.na(.data[[postop_MCS_Impella5.5_DEPENDENT_col]]) &
          is.na(.data[[postop_MCS_Impella5.5_col]]) &
          is.na(.data[[postop_MCS_RVAD_col]]) &
          is.na(.data[[postop_MCS_IABP_col]]) &
          is.na(.data[[postop_VA_ECMO_col]]) &
          is.na(.data[[postop_CVP_col]]) &
          is.na(.data[[postop_cardiac_index_col]]) &
          (is.na(.data[[postop_LVEF_median_col]]) | .data[[postop_LVEF_median_col]] == 0) &
          (is.na(.data[[postop_inotrope_score_col]]) | .data[[postop_inotrope_score_col]] == 0) ~ NA_character_,
        
        # Severe PGD criteria
        .data[[postop_MCS_Impella5.5_DEPENDENT_col]] == "Y" |
          .data[[postop_MCS_RVAD_col]] == "Y" |
          .data[[postop_VA_ECMO_col]] == "Y" ~ "Severe",
        
        # Moderate PGD criteria
        ( (.data[[postop_LVEF_median_col]] < 40 & !is.na(.data[[postop_LVE




#! OUTPUTS
# adds column to input tibble: ISHLT PGD GRADE (mild moderate, severe, none)
# adds column to input tibble: ISHLT_PGD_binary Y/N

#! ORIGINAL FORMULA
# =IF(AND(AJ33="",AL33="",AN33="",AM33="",AQ33="",AO33="",AP33="",AS33=0),"",
  #  IF(OR(AJ33="Y",AL33="Y",AN33="Y"),"Severe",
  #     IF(AND(OR(AND(AQ33<40,AQ33<>""),AO33>15,IF(AP33="",1,AP33)<2),OR(AS33>10,AM33="Y")),"Moderate",
  #        IF(OR(AND(AQ33<40,AQ33<>""),AO33>15,IF(AP33="",1,AP33)<2),"Mild","N"))))

#! ORIGINAL COLUMNS
# postop_MCS_Impella5.5_DEPENDENT = AJ
# postop_MCS_Impella5.5 = AK
# postop_MCS_RVAD = AL
# postop_MCS_IABP = AM
# postop_VA_ECMO = AN
# postop_CVP = AO
# postop_cardiac_index = AP
# postop_LVEF_median = AQ
# postop_inotrope_score = AS

# ! REFERENCE COLUMN TO COMPARE
# postop_PGD_textbook_calc
# postop_PGD_ISHLT

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
