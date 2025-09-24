#* 4: Create Tables
#+ 4.0: Examine Normality
  #- 4.1: Create Temporary binded version to test
    normality_test_data <- T1_data %>%
      left_join(T2_data, by = "Patient") %>%
      left_join(T3_data, by = "Patient")
  #- 4.2: Test normality with TernTablesR
    normality_test <- ternG(
      data = normality_test_data,
      vars = NULL,
      exclude_vars = "Patient",
      group_var = "postop_PGD_ISHLT",
      descriptive = FALSE,
      consider_normality = TRUE,
      print_normality = TRUE
    ) %>%
    filter(!is.na(SW_p_N)) %>%
    select(Variable, SW_p_N, SW_p_Y) %>%
    mutate(
      SW_p_N = as.numeric(SW_p_N),
      SW_p_Y = as.numeric(SW_p_Y)
    ) %>%
    mutate(
      Normality_Status = case_when(
        SW_p_N < 0.05 | SW_p_Y < 0.05 ~ NA_character_,  # Either group non-normal
        SW_p_N >= 0.05 & SW_p_Y >= 0.05 ~ "Normal",     # Both groups normal
        TRUE ~ NA_character_  # Catch any edge cases
      )
    ) %>%
    arrange(Normality_Status)
#+ 4.1: Table 1 (Recipient Preoperative Characteristics)
  T1 <- ternG(
    data = T1_data,
    vars = NULL,
    exclude_vars = "Patient",
    group_var = "postop_PGD_ISHLT",
    descriptive = TRUE,
    consider_normality = TRUE,
    print_normality = FALSE
  )
#+ 4.2: Table 2 (Donor Characteristics)
  T2 <- ternG(
    data = T2_data,
    vars = NULL,
    exclude_vars = "Patient",
    group_var = "postop_PGD_ISHLT",
    descriptive = TRUE,
    consider_normality = TRUE,
    print_normality = FALSE
  )
#+ 4.3: Table 3 (Table 3. Procurement/Surgical Factors and Perioperative/Post-Transplant Outcomes)
  T3 <- ternG(
    data = T3_data,
    vars = NULL,
    exclude_vars = "Patient",
    group_var = "postop_PGD_ISHLT",
    descriptive = TRUE,
    consider_normality = TRUE,
    print_normality = FALSE
  )

total <- rbind(T1,T2,T3) %>%
  arrange(p)
