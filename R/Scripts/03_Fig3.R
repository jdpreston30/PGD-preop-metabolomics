#* 3: Figure 3
  #+ 3.0: Import and structure MSMICA data
    #- 3.0.1: Import
      HILIC_MSMICA <- read_csv("Raw/HILIC_median_summarized_MSMICA.csv")
      C18_HILIC_MSMICA <- read_csv("Raw/C18_median_summarized_MSMICA.csv") %>%
        left_join(HILIC_MSMICA, by = "Sample_ID") %>%
        rename(Patient = Sample_ID) %>%
        filter(str_starts(Patient, "H")) %>%
        mutate(Patient = str_extract(Patient, "H\\d+")) %>%
        mutate(across(
          where(is.numeric),
          ~ ifelse(. == 0 | is.na(.),
            ifelse(any(. > 0, na.rm = TRUE), min(.[. > 0], na.rm = TRUE) / 2, 0),
            .
          )
        )) %>%
        mutate(across(
          where(is.numeric),
          ~ log2(.) # Adding a small constant to avoid issues with zeros
        )) %>%
        left_join(metadata, by = "Patient") %>%
        arrange(PGD) %>%
        select(Patient, PGD, everything()) %>%
        mutate(PGD = as.factor(PGD)) %>%
        arrange(Patient)
      write.csv(C18_HILIC_MSMICA, "C18_HILIC_MSMICA.csv")
      feature_key_flagged <- read_csv("Raw/MSMICA_feature_key.csv") %>%
        group_by(mz, time,ion_mode) %>% # Group by both mz and time
        mutate(
          duplicate_flag = if_else(n() > 1, "Y", "N"), # Flag if there are duplicates
          keep = if_else(row_number() == 1, TRUE, FALSE) # Keep only the first occurrence
        ) %>%
        ungroup()
    #- 3.0.2: Determine number of mass duplicates and number of feature duplicates
      cleaned_names <- gsub("_HILIC|_C18", "", feature_key_flagged$Name)
      duplicate_count <- sum(base::duplicated(cleaned_names))
      duplicate_mass_count <- feature_key_flagged %>%
        mutate(
          mz = as.numeric(mz), # Attempt conversion to numeric
          time = as.numeric(time) # Ensure time is numeric (if applicable)
        ) %>%
        filter(!is.na(mz), !is.na(time)) %>% # Remove any rows with missing values in mz or time
        dplyr::count(mz, time,ion_mode) %>% # Count duplicates based on both mz and time
        filter(n > 1) %>%
        summarise(total_duplicates = sum(n))
    #- 3.0.3: Filter and consolidate any duplicates
      columns_to_keep <- feature_key_flagged %>%
        filter(keep) %>%
        pull(Name)
      C18_HILIC_MSMICA_cleaned <- C18_HILIC_MSMICA %>%
        select(Patient, PGD, all_of(columns_to_keep))
  #+ 3.1: Violin Plots
    #- 3.1.1: Process algorithm targeted data
      #_ Run t-tests 
        feature_key_simple <- feature_key_flagged %>%
          select(Name, Identified_Name, duplicate_flag, Exact_mass,mz,time)
        algorithm_features_sig <- C18_HILIC_MSMICA_cleaned %>%
          select(-Patient, -PGD) %>%
          summarise(across(
            everything(),
            ~ tryCatch(
              t.test(
                .[C18_HILIC_MSMICA_cleaned$PGD == "Yes"],
                .[C18_HILIC_MSMICA_cleaned$PGD == "No"],
                var.equal = TRUE
              )$p.value,
              error = function(e) NA_real_
            )
          )) %>%
          pivot_longer(cols = everything(), names_to = "Name", values_to = "P_Value") %>%
          arrange(P_Value) %>%
          left_join(feature_key_simple, by = "Name") %>%
          mutate(
            Mean_PGD = map_dbl(Name, ~ mean(C18_HILIC_MSMICA_cleaned[[.x]][C18_HILIC_MSMICA_cleaned$PGD == "Yes"], na.rm = TRUE)),
            Mean_No_PGD = map_dbl(Name, ~ mean(C18_HILIC_MSMICA_cleaned[[.x]][C18_HILIC_MSMICA_cleaned$PGD == "No"], na.rm = TRUE)),
            Higher = if_else(Mean_PGD > Mean_No_PGD, "PGD", "No PGD")
          ) %>%
          filter(P_Value < 0.05)
    #- 3.1.2: Process targeted data
      #_ Prepare and put in form for t-tests
        targeted_FT_ttest_ready <- targeted_FT_transposed %>%
        select(CNAME_KEGG_HMDB_col_ad, H1:H36) %>%
        pivot_longer(cols = -CNAME_KEGG_HMDB_col_ad, names_to = "Patient_no", values_to = "Value") %>%
        group_by(Patient_no, CNAME_KEGG_HMDB_col_ad) %>%
        summarise(Value = mean(Value, na.rm = TRUE), .groups = "drop") %>% # Aggregate duplicate values
        pivot_wider(names_from = CNAME_KEGG_HMDB_col_ad, values_from = Value) %>%
        left_join(UFT_C18_HILIC %>% select(Patient_no, PGD), by = "Patient_no") %>%
        select(Patient_no, PGD, everything()) %>%
        rename(Patient = Patient_no)
      #_ Run t-tests
        targeted_FT_ttest_results_sig <- targeted_FT_ttest_ready %>%
          select(-Patient) %>% # Remove patient ID column
          summarise(across(
            -PGD, # Exclude PGD from numeric variables
            ~ tryCatch(
              t.test(
                .[targeted_FT_ttest_ready$PGD == "Yes"], # Values for PGD = Yes
                .[targeted_FT_ttest_ready$PGD == "No"], # Values for PGD = No
                var.equal = TRUE # Assume equal variance
              )$p.value,
              error = function(e) NA_real_ # Handle errors safely
            )
          )) %>%
          pivot_longer(cols = everything(), names_to = "Name", values_to = "P_value") %>%
          arrange(P_value) %>%
          mutate(
            mean_no_PGD = sapply(Name, function(met) mean(targeted_FT_ttest_ready[[met]][targeted_FT_ttest_ready$PGD == "No"], na.rm = TRUE)),
            mean_yes_PGD = sapply(Name, function(met) mean(targeted_FT_ttest_ready[[met]][targeted_FT_ttest_ready$PGD == "Yes"], na.rm = TRUE)),
            Higher = if_else(mean_yes_PGD > mean_no_PGD, "PGD", "No PGD")
          ) %>% 
          mutate(Identified_Name = "-") %>%
          select(Name, P_value, Identified_Name, Higher) %>%
          filter(P_value < 0.05)
    #- 3.1.3: Merge t-test results from both
      algorithm_features_sig_merge_ready <- algorithm_features_sig %>%
        select(Name, P_Value, Identified_Name, Higher) %>%
        mutate(data_source = "Algorithm")
      targeted_FT_ttest_results_merge_ready <- targeted_FT_ttest_results_sig %>%
        select(Name, P_value, Identified_Name, Higher) %>%
        mutate(data_source = "Targeted")
      colnames(algorithm_features_sig_merge_ready) <- colnames(targeted_FT_ttest_results_merge_ready)
      merge_targeted_ttest <- rbind(targeted_FT_ttest_results_merge_ready, algorithm_features_sig_merge_ready) %>%
        arrange(P_value)
    #- 3.1.4: Z-score
      subset_z_scored_targeted <- targeted_FT_ttest_ready %>%
        select(Patient, PGD, all_of(targeted_FT_ttest_results_sig$Name)) %>%
        mutate(across(where(is.numeric), ~ scale(.)[, 1])) %>%
        arrange(PGD)
      subset_z_scored_algorithm <- C18_HILIC_MSMICA_cleaned %>%
        select(Patient,PGD, all_of(algorithm_features_sig$Name)) %>%
        mutate(across(where(is.numeric), ~ scale(.)[, 1])) %>%
        arrange(PGD)
      combined_algo_targeted_z <- subset_z_scored_algorithm %>%
        left_join(subset_z_scored_targeted, by = c("Patient"))
      write.csv(combined_algo_targeted_z, "violins.csv")
      write.csv(merge_targeted_ttest, "merge_targeted_ttest.csv")
  #+ 3.2: Superclasses and Classes (ClassyFire)
    #- 3.2.1: Import and structure
        class_analysis <- read_excel("SM3.xlsx", sheet = "Significant Features") %>%
        select(Identified_Name, "Regulation in PGD", Superclass:Class) %>%
        rename(Regulation = "Regulation in PGD")
        total_regulation_counts <- class_analysis %>%
        group_by(Regulation) %>%
        summarise(Total_Chemicals = n(), .groups = "drop")
        significance_results_superclasses <- class_analysis %>%
        group_by(Superclass, Regulation) %>%
        summarise(Chemical_Count = n(), .groups = "drop") %>%
        pivot_wider(names_from = Regulation, values_from = Chemical_Count, values_fill = 0) %>%
        rowwise() %>%
        mutate(Total = Downregulated + Upregulated,
            Downregulated = Downregulated * (-1)) %>%
        arrange(Upregulated, Downregulated)
        significance_results_classes <- class_analysis %>%
        group_by(Class, Regulation) %>%
        summarise(Chemical_Count = n(), .groups = "drop") %>%
        pivot_wider(names_from = Regulation, values_from = Chemical_Count, values_fill = 0) %>%
        rowwise() %>%
        mutate(Total = Downregulated + Upregulated,
            Downregulated = Downregulated*(-1)) %>%
        filter(Total > 1) %>% # filtered on classes but not superclasses
        arrange(Upregulated,Downregulated)
    #- 3.2.2: Save an export
        write.csv(significance_results_superclasses, "superclasses_05.csv")
        write.csv(significance_results_classes, "classes_05.csv")
    #- 3.2.3: Graph results
      #! Graphed in Prism from here