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
