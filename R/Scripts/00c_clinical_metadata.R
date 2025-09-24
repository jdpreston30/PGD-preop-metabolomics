#* 0d: Importing Clinical Metadata and Preprocess
#+ 0d.0: Set Vectors
  #- 0d.0.1: Set Analyzed Patient Vector
    analyzed_patients <- c("H1", "H2", "H3", "H4", "H5", "H6", "H7", "H8", "H9", "H10",
                         "H11", "H12", "H13", "H14", "H15", "H16", "H17", "H18", "H19", "H20",
                         "H21", "H23", "H24", "H25", "H26", "H27", "H28", "H29", "H30", "H31",
                         "H32", "H33", "H34", "H35", "H36", "H37", "H38", "H39", "H40", "H41",
                         "H42", "H43", "H44", "H45", "H46", "H47", "H48", "H50", "H51", "H52",
                         "H53", "H54", "H55", "H56", "H57", "H58", "H59", "H60", "H61", "H62", "H63", "H64")
  #- 0d.0.2: Set T1 Vector
  #!!!!!!!!!!!!!!!!!! Add back RADIAL
            # "radial_calc",
    T1 <- c("demographics_age_tpx", "demographics_race", "demographics_sex", "demographics_BMI", 
          "comorbidities_smoking_hx", "comorbidities_DM", "comorbidities_prior_cardiac_surg", 
          "preop_temp_MCS",
          "preop_IABP", "preop_imeplla5.5", "preop_VA_ECMO", "preop_LVAD", 
          "rx_preop_inotrope", "rx_preop_amiodarone", "rx_preop_ASA", "preop_MCS_days")	
  #- 0d.0.3: Set T2 Vector
    T2 <- c("donor_age", "donor_sex", "donor_sex_mismatch", "donor_PHM", "donor_LVEF", 
          "donor_drug_use", "donor_PHS_risk", "donor_DBD_DCD", "donor_COD_simplified")
  #- 0d.0.4: Set T3 Vector
    T3 <- c("operative_IT_minutes", "operative_CPB_minutes", "postop_LVEF_median", "postop_CVP", 
          "postop_cardiac_index", "postop_inotrope_score", "postop_MCS_IABP", "postop_VA_ECMO", 
          "postop_MCS_Impella5.5", "postop_MCS_RVAD", "postop_PGD_ISHLT", "postop_ICU_LOS", 
          "postop_RRT_needed", "postop_CRRT", "postop_stroke", "postop_30_day_LVEF", 
          "postop_hospital_LOS", "ACR_2R_or_greater", "survival_30", "survival_90", 
          "survival", "survival_days")
#+ 0d.1: Import Clinical metadata
  #- 0d.1.1: Clinical Data
  preop_i <- read_xlsx(config$paths$clinical_metadata, sheet = "Preop", na = c("", "NA", "-")) %>%
    filter(Patient %in% analyzed_patients)
  periop_i <- read_xlsx(config$paths$clinical_metadata, sheet = "Periop", na = c("", "NA", "-")) %>%
    filter(Patient %in% analyzed_patients)
  outcomes_i <- read_xlsx(config$paths$clinical_metadata, sheet = "Outcomes", na = c("", "NA", "-")) %>%
    filter(Patient %in% analyzed_patients)
  match_run_i <- read_xlsx(config$paths$clinical_metadata, sheet = "Match Run", na = c("", "NA", "-")) %>%
    filter(Patient %in% analyzed_patients)
  #- 0d.1.2: Sample Type Data
#!!!!!!!!!!!!!!!!!!
  # sample_type <- read_xlsx(config$paths$sample_type) %>%
  #   filter(Patient %in% analyzed_patients) %>%
  #   filter(Sample == "S0")
#+ 0d.2: Combine clinical metadata into one tibble; format variables
  clinical_metadata_i <- preop_i %>%
    left_join(periop_i, by = "Patient") %>%
    left_join(outcomes_i, by = "Patient") %>%
    left_join(match_run_i, by = "Patient") %>%
    select(-ends_with(".x"), -ends_with(".y")) %>%
    mutate(across(where(is.character), as.factor))
#+ 0d.4: Compute RADIAL score, PHM, and ISHLT PGD Status
#   clinical_metadata <- clinical_metadata_i %>%
#     calc_radial(
#       rap_col = "preop_RAP",
#       age_col = "demographics_age_tpx",
#       dm_col = "comorbidities_DM",
#       inotrope_col = "rx_preop_inotrope",
#       donor_age_col = "donor_age",
#       ischemic_time_col = "operative_IT_minutes"
#     ) %>%
#     calc_PHM() %>%
#     calc_ISHLT()
# #+ 0d.4: Break into components for the final tables
  T1_data <- clinical_metadata_i %>%
    select(Patient, all_of(T1))
  T2_data <- clinical_metadata_i %>%
    select(Patient, all_of(T2))
  T3_data <- clinical_metadata_i %>%
    select(Patient, all_of(T3))
