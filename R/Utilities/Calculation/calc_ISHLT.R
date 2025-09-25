calc_ISHLT <- function(clinical_metadata_i,
                       impella_dep_col = "postop_MCS_Impella5.5_DEPENDENT",
                       mcs_impella_col = "postop_MCS_Impella5.5",
                       rvad_col = "postop_MCS_RVAD",
                       iabp_col = "postop_MCS_IABP",
                       ecmo_col = "postop_VA_ECMO",
                       cvp_col = "postop_CVP",
                       cardiac_index_col = "postop_cardiac_index",
                       lvef_col = "postop_LVEF_median",
                       inotrope_col = "postop_inotrope_score") {
  
  clinical_metadata <- clinical_metadata_i
  original_PGD <- clinical_metadata_i %>% select(postop_PGD_textbook_calc, postop_PGD_ISHLT)

  # Check column names exist
  missing_cols <- c()
  for (col in c(impella_dep_col,
                mcs_impella_col,
                rvad_col,
                iabp_col,
                ecmo_col,
                cvp_col,
                cardiac_index_col,
                lvef_col,
                inotrope_col)) {
    if (!col %in% colnames(clinical_metadata)) {
      missing_cols <- c(missing_cols, col)
    }
  }
  
  if (length(missing_cols) > 0) {
    stop(paste("Error: The following required columns are missing from the input data:", 
               paste(missing_cols, collapse = ", ")))
  }
  
  # Calculate ISHLT PGD Grade
  clinical_metadata <- clinical_metadata %>%
    mutate(
      postop_PGD_grade_ISHLT = case_when(
        # Check if all values are empty/NA (return empty string)
        is.na(.data[[impella_dep_col]]) & is.na(.data[[rvad_col]]) & 
        is.na(.data[[ecmo_col]]) & is.na(.data[[iabp_col]]) & 
        is.na(.data[[cvp_col]]) & is.na(.data[[cardiac_index_col]]) & 
        is.na(.data[[lvef_col]]) & 
        (is.na(.data[[inotrope_col]]) | .data[[inotrope_col]] == 0) ~ "",
        
        # Check for Severe PGD first (any mechanical support)
        .data[[ecmo_col]] == "Y" | 
        .data[[rvad_col]] == "Y" | 
        .data[[impella_dep_col]] == "Y" ~ "Severe",
        
        # Moderate PGD: hemodynamic compromise AND (high inotrope OR IABP)
        ((.data[[lvef_col]] <= 40 & !is.na(.data[[lvef_col]])) |
         .data[[cvp_col]] > 15 |
         (if_else(is.na(.data[[cardiac_index_col]]), 1, .data[[cardiac_index_col]]) < 2)) &
        (.data[[inotrope_col]] > 10 | .data[[iabp_col]] == "Y") ~ "Moderate",
        
        # Mild PGD: hemodynamic compromise AND inotrope 1-10
        ((.data[[lvef_col]] <= 40 & !is.na(.data[[lvef_col]])) |
         .data[[cvp_col]] > 15 |
         (if_else(is.na(.data[[cardiac_index_col]]), 1, .data[[cardiac_index_col]]) < 2)) &
        (.data[[inotrope_col]] > 0 & .data[[inotrope_col]] <= 10) ~ "Mild",
        
        # Default: No PGD
        TRUE ~ "N"
      ),
      
      postop_PGD_binary_ISHLT = case_when(
        postop_PGD_grade_ISHLT == "" ~ "",
        postop_PGD_grade_ISHLT == "N" ~ "N", 
        TRUE ~ "Y"
      )
    )

  return(clinical_metadata)
}

results <- calc_ISHLT(clinical_metadata)
names(results)

# Binary mismatches
results %>%
  filter(postop_PGD_ISHLT != postop_PGD_binary_ISHLT) %>%
  select(postop_PGD_ISHLT, postop_PGD_binary_ISHLT)

# Grade mismatches
results %>%
  filter(postop_PGD_textbook_calc != postop_PGD_grade_ISHLT) %>%
  select(postop_PGD_textbook_calc, postop_PGD_grade_ISHLT)

sum(results$postop_PGD_ISHLT != results$postop_PGD_binary_ISHLT, na.rm = TRUE)
sum(results$postop_PGD_textbook_calc != results$postop_PGD_grade_ISHLT, na.rm = TRUE)




#+ Calculate ISHLT PGD Grade ----
## returns tibble with two new columns: ISHLT_PGD_grade (mild, moderate, severe, none)
## and ISHLT_PGD_binary (Y/N)

# #* Define PGD Criteria

# # Mild PGD criteria
# mild_PGD <- (LVEF_median_col, RAP_col, cardiac_index_col, inotrope_score_col)
# LVEF_median_col <= 40 | RAP_col > 15 & cardiac_index_col < 2 
# & inotrope_score_col > 1 & inotrope_score_col < 10

# # Moderate PGD criteria
# moderate_PGD <- (LVEF_median_col, RAP_col, cardiac_index_col, inotrope_score_col, MCS_IABP_col)
# LVEF_median_col <= 40 | RAP_col > 15 & cardiac_index_col < 2 & inotrope_score_col < 10
# & 
# inotrope_score_col > 10 | MCS_IABP_col == "Y"

# # Severe PGD criteria
# severe_PGD <- (VA_ECMO_col, MCS_RVAD_col, Impella5.5_dep_col)
# VA_ECMO_col == "Y" | MCS_RVAD_col == "Y" | Impella5.5_dep_col == "Y"



# #! OUTPUTS ----
# # adds column to input tibble: ISHLT PGD GRADE (mild moderate, severe, none)
# # adds column to input tibble: ISHLT_PGD_binary Y/N


# #! ORIGINAL FORMULA
# # =IF(AND(AJ33="",AL33="",AN33="",AM33="",AQ33="",AO33="",AP33="",AS33=0),"",
#   #  IF(OR(AJ33="Y",AL33="Y",AN33="Y"),"Severe",
#   #     IF(AND(OR(AND(AQ33<40,AQ33<>""),AO33>15,IF(AP33="",1,AP33)<2),OR(AS33>10,AM33="Y")),"Moderate",
#   #        IF(OR(AND(AQ33<40,AQ33<>""),AO33>15,IF(AP33="",1,AP33)<2),"Mild","N"))))

# #! ORIGINAL COLUMNS
# # postop_MCS_Impella5.5_DEPENDENT = AJ
# # postop_MCS_Impella5.5 = AK
# # postop_MCS_RVAD = AL
# # postop_MCS_IABP = AM
# # postop_VA_ECMO = AN
# # postop_CVP = AO
# # postop_cardiac_index = AP
# # postop_LVEF_median = AQ
# # postop_inotrope_score = AS

# # ! REFERENCE COLUMN TO COMPARE
# # postop_PGD_textbook_calc
# # postop_PGD_ISHLT

