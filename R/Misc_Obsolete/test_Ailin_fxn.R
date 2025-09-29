clinical_meatadata_PHM <- clinical_metadata %>%
  select(Patient, donor_PHM, donor_PHM_calc) %>%
  mutate(PHM_match = floor(donor_PHM) == floor(donor_PHM_calc)) %>%
  filter(PHM_match == FALSE)
#! This proves that Ailin's function produced the same results within one integer as the base Excel based calculation

clinical_metadata_PGD_bin <- clinical_metadata %>%
  select(Patient, postop_PGD_ISHLT, postop_PGD_binary_ISHLT) %>%
  mutate(PGD_bin_match = postop_PGD_ISHLT == postop_PGD_binary_ISHLT) %>%
  filter(PGD_bin_match == FALSE)

clinical_metadata_PGD <- clinical_metadata %>%
  select(Patient, postop_PGD_textbook_calc, postop_PGD_grade_ISHLT) %>%
  mutate(PGD_grade_match = postop_PGD_textbook_calc == postop_PGD_grade_ISHLT) %>%
  filter(PGD_grade_match == FALSE)
  
  #! This proves that Ailin's function produced the same results within one integer as the base Excel based calculation