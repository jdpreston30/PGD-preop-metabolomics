#* 4: Tables: Import, merge, and structure all data
  #+ 4.1: Import raw data
    master_sheet <- "/Users/jdp2019/Library/CloudStorage/OneDrive-EmoryUniversity/Research/Manuscripts and Projects/Active Projects/TPMO/OHT Clinical Data Master Sheet.xlsx"
    preop_raw <- read_excel(master_sheet, sheet = "Preop")
    periop_raw <- read_excel(master_sheet, sheet = "Periop")
    match_run_raw <- read_excel(master_sheet, sheet = "Match Run")
    outcomes_raw <- read_excel(master_sheet, sheet = "Outcomes")
  #+ 4.2: Merge raw data, remove non-analyzed patients
    clinical_data_raw <- preop_raw %>%
      left_join(periop_raw, by = "Patient") %>%
      left_join(match_run_raw, by = "Patient") %>%
      left_join(outcomes_raw, by = "Patient") %>%
      filter(!(Patient == "H22" | as.numeric(gsub("H", "", Patient)) >= 37)) %>%
      arrange(Patient_no.x) #Only select patients in PGD metabolomics study
  #+ 4.3: Structure tables
    #- 4.3.1: Table 1
      table1_raw_i <- clinical_data_raw %>%
        select(
          Patient, postop_PGD, demographics_age_tpx, demographics_race, demographics_sex, demographics_BMI, comorbidities_smoking_hx, comorbidities_DM,comorbidities_prior_cardiac_surg,rx_preop_amiodarone,rx_preop_ASA, rx_preop_inotrope, preop_temp_MCS, preop_temp_MCS_details,preop_LVAD,recipient_UNOS_status, recipient_NICM_ICM_cong, preop_PVR,preop_labs_WBC, preop_labs_Hgb, preop_labs_Plt, preop_labs_sodium,preop_labs_creatinine, preop_labs_GFR, preop_labs_alkphos, preop_labs_AST,preop_labs_ALT, preop_labs_albumin, preop_labs_bilirubin) %>%
        mutate(across(c(postop_PGD,demographics_race,demographics_sex, comorbidities_smoking_hx,comorbidities_DM,comorbidities_prior_cardiac_surg,rx_preop_amiodarone, rx_preop_ASA,rx_preop_inotrope, preop_temp_MCS,preop_temp_MCS_details, preop_LVAD,comorbidities_prior_cardiac_surg,recipient_NICM_ICM_cong), as.factor)) %>%
        mutate(across(where(is.character) & !all_of("Patient"), ~ na_if(.x, "-"))) %>% # Convert "-" to NA (excluding "Patient")
        mutate(across(where(is.character) & !all_of("Patient"), as.numeric))
    #- 4.3.2: Table 2
      table2_raw <- clinical_data_raw %>%                   
        select(Patient,postop_PGD,donor_age,donor_sex,donor_PHM,donor_LVEF,donor_COD_simplified,donor_DBD_DCD,donor_sex_mismatch,donor_drug_use,donor_PHS_risk) %>%
        mutate(across(c(postop_PGD,donor_sex,donor_sex_mismatch,donor_COD_simplified,donor_DBD_DCD,donor_drug_use,donor_PHS_risk), as.factor)) %>%
        mutate(across(where(is.character) & !all_of("Patient"), ~ na_if(.x, "-"))) %>% # Convert "-" to NA (excluding "Patient")
        mutate(across(where(is.character) & !all_of("Patient"), as.numeric))
    #- 4.3.3: Table 3
      table3_raw <- clinical_data_raw %>%
        select(Patient,postop_PGD,operative_IT_minutes, operative_CPB_minutes,postop_30_day_LVEF,postop_ICU_LOS,postop_hospital_LOS,ACR_2R_or_greater,survival_90,postop_stroke,postop_PGD_grade,postop_VA_ECMO,postop_RRT_needed) %>%
        mutate(across(c(postop_PGD,ACR_2R_or_greater, survival_90, postop_stroke, postop_PGD_grade, postop_VA_ECMO, postop_RRT_needed), as.factor)) %>%
        mutate(across(where(is.character) & !all_of("Patient"), ~ na_if(.x, "-"))) %>% # Convert "-" to NA (excluding "Patient")
        mutate(across(where(is.character) & !all_of("Patient"), as.numeric))
    #- 4.3.4: Calculate RADIAL score and add to table 1
      #_Calculate radial
        radial <- clinical_data_raw %>%
          mutate(
            radial_calc = rowSums(
              cbind(
                preop_RAP >= 10, # Recipient right atrial pressure ≥ 10 mmHg
                demographics_age_tpx >= 60, # Recipient age ≥ 60 years
                comorbidities_DM == "Yes", # Recipient diabetes mellitus
                rx_preop_inotrope == "Yes", # Recipient inotrope dependence
                donor_age >= 30, # Donor age ≥ 30 years (from table2_raw)
                operative_IT_minutes >= 240 # Ischemic time ≥ 240 minutes (from table3_raw)
              ),
              na.rm = TRUE # Ignore NA values in row-wise summation
            )
          ) %>%
          select(Patient, radial_calc)
      #_Add to table 1
        table1_raw <- table1_raw_i %>%
          left_join(radial, by = "Patient")
  #+ 4.4: Define variables into families for which analysis they will undergo
    #- 4.4.1: Dichotomous YN categorical variables (factors with two levels)
      dichotomous_categorical <- c(
        "comorbidities_smoking_hx", "comorbidities_DM",
        "comorbidities_prior_cardiac_surg", "rx_preop_amiodarone", "rx_preop_ASA","rx_preop_inotrope",
        "preop_temp_MCS", "preop_LVAD", "donor_sex_mismatch",
        "donor_drug_use", "donor_PHS_risk", "survival_90", "ACR_2R_or_greater",
        "postop_stroke", "postop_VA_ECMO", "postop_RRT_needed"
      )
    #- 4.4.2: Dichotomous Named categorical variables (factors with two levels)
      dichotomous_categorical_nominal <- c(
        "demographics_sex","donor_sex","recipient_NICM_ICM_cong","donor_DBD_DCD"
      )
    #- 4.4.3: Define multinomial categorical variables (factors with more than 2 levels)
      multinomial_categorical <- c(
        "demographics_race", "preop_temp_MCS_details",
        "donor_COD_simplified", "postop_PGD_grade"
      )
    #- 4.4.4: Define ratio continuous variables
      ratio_cont <- c(
        "demographics_age_tpx", "demographics_BMI",
        "preop_PVR", "radial_calc", "preop_labs_WBC", "preop_labs_Hgb",
        "preop_labs_Plt", "preop_labs_sodium", "preop_labs_creatinine",
        "preop_labs_GFR", "preop_labs_alkphos", "preop_labs_AST", "preop_labs_ALT",
        "preop_labs_albumin", "preop_labs_bilirubin", "donor_age", "donor_PHM",
        "donor_LVEF", "operative_IT_minutes", "operative_CPB_minutes",
        "postop_30_day_LVEF", "postop_ICU_LOS", "postop_hospital_LOS"
      )
    #- 4.4.5: Define ordinal discrete variables
      ordinal_discrete <- c("recipient_UNOS_status")
  #+ 4.5: Analyze tables and output as CSV
    #- 4.5.1: Table 1: Recipient Characteristics
      t1_results <- analyze_table(
        data = table1_raw,
        cont_vars = ratio_cont,
        dichotomous_vars = dichotomous_categorical,
        dichotomous_nominal_vars = dichotomous_categorical_nominal,
        ordinal_vars = ordinal_discrete
      )
      t1_results_multi <- analyze_table_multinomial(table1_raw, multinomial_categorical)
      write.csv(t1_results, "table1_summary.csv")
      write.csv(t1_results_multi, "table1_multinomial_summary.csv")
    #- 4.5.2: Table 2: Donor Characteristics
      t2_results <- analyze_table(
        data = table2_raw,
        cont_vars = ratio_cont,
        dichotomous_vars = dichotomous_categorical,
        dichotomous_nominal_vars = dichotomous_categorical_nominal,
        ordinal_vars = ordinal_discrete
      )
      t2_results_multi <- analyze_table_multinomial(table2_raw, multinomial_categorical)
      write.csv(t2_results, "table2_summary.csv")
      write.csv(t2_results_multi, "table2_multinomial_summary.csv")
    #- 4.5.3: Table 3: Periop and Outcomes
      t3_results <- analyze_table(
        data = table3_raw,
        cont_vars = ratio_cont,
        dichotomous_vars = dichotomous_categorical,
        dichotomous_nominal_vars = dichotomous_categorical_nominal,
        ordinal_vars = ordinal_discrete
      )
      t3_results_multi <- analyze_table_multinomial(table3_raw, multinomial_categorical)
      write.csv(t3_results, "table3_summary.csv")
      write.csv(t3_results_multi, "table3_multinomial_summary.csv")