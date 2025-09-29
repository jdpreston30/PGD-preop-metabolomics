calc_ISHLT <- function(clinical_metadata_i,
                       impella_dep_col = "postop_MCS_Impella5.5_DEPENDENT",
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
