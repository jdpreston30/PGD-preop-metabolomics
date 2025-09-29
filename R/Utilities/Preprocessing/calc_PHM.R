calc_PHM <- function(clinical_metadata, 
                     donor_age_col = "donor_age",
                     donor_sex_col = "donor_sex",
                     donor_weight_col = "donor_weight",
                     donor_height_col = "donor_height") {

  clinical_metadata <- clinical_metadata %>%
    mutate(
      donor_PHM_calc = case_when(
        .data[[donor_sex_col]] == "Female" ~ (6.82 * (.data[[donor_height_col]] / 100)^0.54 * .data[[donor_weight_col]]^0.61) + (10.59 * .data[[donor_age_col]]^-0.32 * (.data[[donor_height_col]] / 100)^1.135 * .data[[donor_weight_col]]^0.315),
        TRUE ~ (8.25 * (.data[[donor_height_col]] / 100)^0.54 * .data[[donor_weight_col]]^0.61) + (11.25 * .data[[donor_age_col]]^-0.32 * (.data[[donor_height_col]] / 100)^1.135 * .data[[donor_weight_col]]^0.315)
      )
    )

  return(clinical_metadata)
}