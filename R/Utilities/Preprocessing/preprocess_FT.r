#' Preprocess Feature Table for PGD Analysis
#'
#' Performs standardized preprocessing of metabolomic feature tables including
#' sample ID correction, patient ID extraction, filtering, and clinical metadata
#' integration for primary graft dysfunction (PGD) analysis.
#'
#' @param df Data frame containing raw feature table with Sample_ID column
#'
#' @return Processed data frame with:
#'   - Corrected sample IDs
#'   - Extracted Patient and Sample identifiers  
#'   - Filtered to baseline samples (S0) only
#'   - Excluded problematic patients (H49)
#'   - Integrated PGD clinical metadata
#'   - Proper factor conversions for statistical analysis
#'
#' @details
#' Processing steps include:
#' 1. **Sample ID correction**: Fixes known ID error (H46SS0 -> H46S0)
#' 2. **Patient extraction**: Extracts patient numbers from Sample_ID (H##)
#' 3. **Sample filtering**: Keeps only baseline samples (S0)
#' 4. **Patient filtering**: Removes patient H49 (problematic data)
#' 5. **Metadata integration**: Joins with PGD_specifics clinical data
#' 6. **Factor conversion**: Converts categorical variables to factors
#' 7. **Column organization**: Reorders columns for analysis workflow
#'
#' **Required external data**: PGD_specifics table must be available in environment
#' 
#' **Expected Sample_ID format**: H##S# (e.g., H01S0, H23S1)
#'
#' @examples
#' \dontrun{
#'   # Preprocess untargeted feature table
#'   processed_FT <- preprocess_FT(raw_feature_table)
#'   
#'   # Check processing results
#'   table(processed_FT$severe_PGD)
#'   summary(processed_FT$Patient)
#' }
#'
#' @export
preprocess_FT <- function(df) {
  df %>%
    mutate(Sample_ID = if_else(Sample_ID == "H46SS0", "H46S0", Sample_ID)) %>%
    mutate(
      Patient_temp = str_extract(Sample_ID, "H\\d+"),
      Patient_num = as.numeric(str_extract(Patient_temp, "\\d+")),
      Sample = str_extract(Sample_ID, "S\\d+")
    ) %>%
    arrange(Patient_num, Sample) %>%
    mutate(
      Patient = paste0("H", Patient_num)
    ) %>%
    select(Sample_ID, Patient, Sample, everything(), -Patient_temp, -Patient_num) %>%
    filter(Sample == "S0") %>%
    filter(Patient != "H49") %>%
    left_join(PGD_specifics, by = "Patient") %>%
    select(Patient, severe_PGD, PGD_grade_tier, any_PGD, everything(), -c(Sample_ID, Sample, postop_PGD_grade_ISHLT, postop_PGD_binary_ISHLT)) %>%
    mutate(PGD_grade_tier = as.factor(PGD_grade_tier)) %>%
    mutate(severe_PGD = as.factor(severe_PGD)) %>%
    mutate(Patient = factor(Patient))
}
