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
    left_join(pgd_status, by = "Patient") %>%
    select(Patient, PGD, everything(), -c(Sample_ID, Sample)) %>%
    mutate(PGD = as.factor(PGD)) %>%
    mutate(Patient = factor(Patient))
}
