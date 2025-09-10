#* Figure 1
  #+ 1A) Heatmap
    # ! Created in Metaboanalyst
  #+ 1B) PLS-DA
    #- Prepare data
      X <- UFT_C18_HILIC[, -c(1, 2)] # Drop 'Patient_no' and 'PGD' columns
      Y <- UFT_C18_HILIC$PGD # The response variable
    #- Fit PLS-DA model
      plsda_model <- plsda(X, Y, ncomp = 2)
    #- Extract scores for the first two components
      scores <- plsda_model$variates$X
    #- Correctly calculate explained variance using the model's eigenvalues
      explained_variance <- round(plsda_model$prop_expl_var$X[1:2] * 100)
    #- Create data frame for ggplot
      scores_df <- data.frame(
        Comp1 = scores[, 1],
        Comp2 = scores[, 2],
        PGD = Y
      )
    #- Assign colors and ellipses colors
      ellipse_colors <- c("Yes" = "#D8919A", "No" = "#87A6C7", "Control" = "#B0B0B0")
      point_colors <- c("Yes" = "#800017", "No" = "#113d6a", "Control" = "#4c4c4c")
    #- Graph
      fig2b <- ggplot(scores_df, aes(x = Comp1, y = Comp2, color = PGD)) +
        geom_point(size = 3, shape = 21, stroke = 0.8, fill = point_colors[scores_df$PGD]) +
        stat_ellipse(geom = "polygon", aes(fill = PGD), alpha = 0.3, color = NA) +
        scale_color_manual(values = point_colors) +
        scale_fill_manual(values = ellipse_colors) +
        theme_minimal(base_family = "Arial") +
        labs(
          x = paste0("Component 1 (", explained_variance[1], "%)"),
          y = paste0("Component 2 (", explained_variance[2], "%)")
        ) +
        theme(
          axis.title = element_text(size = 25, face = "bold"), # Scaled up
          axis.text = element_text(size = 22, face = "bold", color = "black"), # Black axis text
          legend.position = "none",
          panel.grid.major = element_line(color = "gray80", size = 0.8, linetype = "solid"), # Scaled grid
          panel.grid.minor = element_blank(),
          panel.border = element_rect(color = "black", fill = NA, linewidth = 3.2), # Scaled frame
          panel.background = element_blank()
        )
        fig2b
    #-Save as SVG with 1:1 ratio
      ggsave(
        filename = "fig2b.svg",
        plot = fig2b,
        device = "svg",
        width = 8, # Set width and height to be the same for 1:1 aspect ratio
        height = 8,
        units = "in",
        dpi = 600 # Ensure high resolution if needed
      )
  #+ 1C) Volcano Plot
    ttest_results_sig <- UFT_C18_HILIC %>%
      select(-Patient_no) %>%
      pivot_longer(-PGD, names_to = "Feature", values_to = "Log2_Value") %>%
      group_by(Feature) %>%
      summarise(
        # Reverse log2 transformation to calculate original means
        mean_yes = mean(2^Log2_Value[PGD == "Yes"], na.rm = TRUE),
        mean_no = mean(2^Log2_Value[PGD == "No"], na.rm = TRUE),
        mean_ratio = mean_yes / mean_no,

        # p-value using log2-transformed data
        p_value = t.test(Log2_Value[PGD == "Yes"], Log2_Value[PGD == "No"], var.equal = TRUE)$p.value,
        neg_log_p = -log10(p_value),

        # Calculate log2FC using original means
        log2FC = log2(mean_ratio),
        .groups = "drop"
      ) %>%
      mutate(
        # Assign color based on log2FC and p-value threshold
        color = case_when(
          p_value < 0.05 & log2FC >= log2(1.5) ~ "red", # Upregulated (≥ 1.5-fold & significant)
          p_value < 0.05 & log2FC <= -log2(1.5) ~ "blue", # Downregulated (≤ 1/1.5-fold & significant)
          TRUE ~ "black" # Non-significant
        )
      ) %>%
      arrange(desc(color))
    write.csv(ttest_results_sig, "volcano.csv")
    number_down <- nrow(ttest_results_sig %>%
      filter(color == "blue"))
    number_up <- nrow(ttest_results_sig %>%
      filter(color == "red"))
    number_sig <- nrow(ttest_results_sig %>%
      filter(p_value <= 0.05))
    # ! Graphed from here in Prism
#* Figure 2
  #+ 2A) Pathway Enrichment
    #- Filter to relevant columns
      pathway_enrich_raw <- UFT_C18_HILIC %>%
        select(-Patient_no) %>%
        mutate(PGD = as.factor(PGD))
    #- Run ttest of each feature and format for metaboanalyst
      ttest_results_pathway <- pathway_enrich_raw %>%
        pivot_longer(cols = -PGD, names_to = "Feature", values_to = "Value") %>%
        group_by(Feature) %>%
        summarize(
          p_value = t.test(Value[PGD == "Yes"], Value[PGD == "No"])$p.value,
          mean_PGD_yes = mean(Value[PGD == "Yes"], na.rm = TRUE),
          mean_PGD_no = mean(Value[PGD == "No"], na.rm = TRUE)
        ) %>%
        arrange(p_value) %>%
        separate(Feature, into = c("mode", "m.z", "r.t"), sep = "_", convert = TRUE) %>%
        mutate(
          mode = ifelse(mode == "HILIC", "positive", "negative"),
          p.value = p_value # Rename p_value to p.value
        ) %>%
        select(m.z, mode, p.value, r.t) 
      write.csv(ttest_results_pathway, "pathway_enrichment_data.csv", row.names = FALSE)
    #- Import results from mummichog
      pathway_enrich_results <- read_excel("Outputs/mummichog.xlsx", sheet = "summary") %>%
        select(pathway_name, p_gamma, enrichment_factor) %>%
        filter(p_gamma < 0.05) %>%
        arrange(desc(enrichment_factor), p_gamma) # Sort by bubble size (enrichment factor)
    #- Create the balloon plot
      ggplot(pathway_enrich_results, aes(
        x = 1, y = reorder(pathway_name, enrichment_factor),
        size = enrichment_factor, color = p_gamma
      )) +
        geom_point(alpha = 0.8) + # Bubbles with some transparency
        scale_size_continuous(
          range = c(3, 15), name = "Enrichment Factor"
        ) +
        guides(size = guide_legend(reverse = TRUE)) + # Reverse the legend
        scale_color_gradient(
          low = "#800017", high = "#EFD8DC", name = "P-Value"
        ) +
        theme_minimal(base_family = "Arial") +
        theme(
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_text(size = 16, face = "bold", color = "black"), # Ensures pure black Y-axis text
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          legend.title = element_text(size = 16, face = "bold"),
          legend.text = element_text(size = 16),
          legend.key.height = unit(1.5, "cm"), # Adjust space between keys to center title vertically
          legend.text.align = 0.5 # Center-align legend text horizontally
        )
  #+ 2B) KEGG Map
    #! Done on Metaboanalyst
#* Figure 3
  #+ Import and structure MSMICA data
    #- Import
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
    #- Determine number of mass duplicates and number of feature duplicates
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
    #- Filter and consolidate any duplicates
      columns_to_keep <- feature_key_flagged %>%
        filter(keep) %>%
        pull(Name)
      C18_HILIC_MSMICA_cleaned <- C18_HILIC_MSMICA %>%
        select(Patient, PGD, all_of(columns_to_keep))
  #+ 3A) Violin Plots
    #- Process algorithm targeted data
      #_Run t-tests 
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
    #- Process targeted data
      #_Prepare and put in form for t-tests
        targeted_FT_ttest_ready <- targeted_FT_transposed %>%
        select(CNAME_KEGG_HMDB_col_ad, H1:H36) %>%
        pivot_longer(cols = -CNAME_KEGG_HMDB_col_ad, names_to = "Patient_no", values_to = "Value") %>%
        group_by(Patient_no, CNAME_KEGG_HMDB_col_ad) %>%
        summarise(Value = mean(Value, na.rm = TRUE), .groups = "drop") %>% # Aggregate duplicate values
        pivot_wider(names_from = CNAME_KEGG_HMDB_col_ad, values_from = Value) %>%
        left_join(UFT_C18_HILIC %>% select(Patient_no, PGD), by = "Patient_no") %>%
        select(Patient_no, PGD, everything()) %>%
        rename(Patient = Patient_no)
      #_Run t-tests
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
    #- Merge t-test results from both
      algorithm_features_sig_merge_ready <- algorithm_features_sig %>%
        select(Name, P_Value, Identified_Name, Higher) %>%
        mutate(data_source = "Algorithm")
      targeted_FT_ttest_results_merge_ready <- targeted_FT_ttest_results_sig %>%
        select(Name, P_value, Identified_Name, Higher) %>%
        mutate(data_source = "Targeted")
      colnames(algorithm_features_sig_merge_ready) <- colnames(targeted_FT_ttest_results_merge_ready)
      merge_targeted_ttest <- rbind(targeted_FT_ttest_results_merge_ready, algorithm_features_sig_merge_ready) %>%
        arrange(P_value)
    #- Z-score
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
  #+ 3B and C) Superclasses and Classes(ClassyFire)
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
    #- Save an export
      write.csv(significance_results_superclasses, "superclasses_05.csv")
      write.csv(significance_results_classes, "classes_05.csv")
      #! Graphed in Prism from here
#* Tables: Import, merge, and structure all data
  #+ Import raw data
    master_sheet <- "/Users/jdp2019/Library/CloudStorage/OneDrive-EmoryUniversity/Research/Manuscripts and Projects/Active Projects/TPMO/OHT Clinical Data Master Sheet.xlsx"
    preop_raw <- read_excel(master_sheet, sheet = "Preop")
    periop_raw <- read_excel(master_sheet, sheet = "Periop")
    match_run_raw <- read_excel(master_sheet, sheet = "Match Run")
    outcomes_raw <- read_excel(master_sheet, sheet = "Outcomes")
  #+ Merge raw data, remove non-analyzed patients
    clinical_data_raw <- preop_raw %>%
      left_join(periop_raw, by = "Patient") %>%
      left_join(match_run_raw, by = "Patient") %>%
      left_join(outcomes_raw, by = "Patient") %>%
      filter(!(Patient == "H22" | as.numeric(gsub("H", "", Patient)) >= 37)) %>%
      arrange(Patient_no.x) #Only select patients in PGD metabolomics study
  #+ Structure tables
    #- Table 1
      table1_raw_i <- clinical_data_raw %>%
        select(
          Patient, postop_PGD, demographics_age_tpx, demographics_race, demographics_sex, demographics_BMI, comorbidities_smoking_hx, comorbidities_DM,comorbidities_prior_cardiac_surg,rx_preop_amiodarone,rx_preop_ASA, rx_preop_inotrope, preop_temp_MCS, preop_temp_MCS_details,preop_LVAD,recipient_UNOS_status, recipient_NICM_ICM_cong, preop_PVR,preop_labs_WBC, preop_labs_Hgb, preop_labs_Plt, preop_labs_sodium,preop_labs_creatinine, preop_labs_GFR, preop_labs_alkphos, preop_labs_AST,preop_labs_ALT, preop_labs_albumin, preop_labs_bilirubin) %>%
        mutate(across(c(postop_PGD,demographics_race,demographics_sex, comorbidities_smoking_hx,comorbidities_DM,comorbidities_prior_cardiac_surg,rx_preop_amiodarone, rx_preop_ASA,rx_preop_inotrope, preop_temp_MCS,preop_temp_MCS_details, preop_LVAD,comorbidities_prior_cardiac_surg,recipient_NICM_ICM_cong), as.factor)) %>%
        mutate(across(where(is.character) & !all_of("Patient"), ~ na_if(.x, "-"))) %>% # Convert "-" to NA (excluding "Patient")
        mutate(across(where(is.character) & !all_of("Patient"), as.numeric))
    #- Table 2
      table2_raw <- clinical_data_raw %>%                   
        select(Patient,postop_PGD,donor_age,donor_sex,donor_PHM,donor_LVEF,donor_COD_simplified,donor_DBD_DCD,donor_sex_mismatch,donor_drug_use,donor_PHS_risk) %>%
        mutate(across(c(postop_PGD,donor_sex,donor_sex_mismatch,donor_COD_simplified,donor_DBD_DCD,donor_drug_use,donor_PHS_risk), as.factor)) %>%
        mutate(across(where(is.character) & !all_of("Patient"), ~ na_if(.x, "-"))) %>% # Convert "-" to NA (excluding "Patient")
        mutate(across(where(is.character) & !all_of("Patient"), as.numeric))
    #- Table 3
      table3_raw <- clinical_data_raw %>%
        select(Patient,postop_PGD,operative_IT_minutes, operative_CPB_minutes,postop_30_day_LVEF,postop_ICU_LOS,postop_hospital_LOS,ACR_2R_or_greater,survival_90,postop_stroke,postop_PGD_grade,postop_VA_ECMO,postop_RRT_needed) %>%
        mutate(across(c(postop_PGD,ACR_2R_or_greater, survival_90, postop_stroke, postop_PGD_grade, postop_VA_ECMO, postop_RRT_needed), as.factor)) %>%
        mutate(across(where(is.character) & !all_of("Patient"), ~ na_if(.x, "-"))) %>% # Convert "-" to NA (excluding "Patient")
        mutate(across(where(is.character) & !all_of("Patient"), as.numeric))
    #- Calculate RADIAL score and add to table 1
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
  #+ Define variables into families for which analysis they will undergo
    #- Dichotomous YN categorical variables (factors with two levels)
      dichotomous_categorical <- c(
        "comorbidities_smoking_hx", "comorbidities_DM",
        "comorbidities_prior_cardiac_surg", "rx_preop_amiodarone", "rx_preop_ASA","rx_preop_inotrope",
        "preop_temp_MCS", "preop_LVAD", "donor_sex_mismatch",
        "donor_drug_use", "donor_PHS_risk", "survival_90", "ACR_2R_or_greater",
        "postop_stroke", "postop_VA_ECMO", "postop_RRT_needed"
      )
    #- Dichotomous Named categorical variables (factors with two levels)
      dichotomous_categorical_nominal <- c(
        "demographics_sex","donor_sex","recipient_NICM_ICM_cong","donor_DBD_DCD"
      )
    #- Define multinomial categorical variables (factors with more than 2 levels)
      multinomial_categorical <- c(
        "demographics_race", "preop_temp_MCS_details",
        "donor_COD_simplified", "postop_PGD_grade"
      )
    #- Define ratio continuous variables
      ratio_cont <- c(
        "demographics_age_tpx", "demographics_BMI",
        "preop_PVR", "radial_calc", "preop_labs_WBC", "preop_labs_Hgb",
        "preop_labs_Plt", "preop_labs_sodium", "preop_labs_creatinine",
        "preop_labs_GFR", "preop_labs_alkphos", "preop_labs_AST", "preop_labs_ALT",
        "preop_labs_albumin", "preop_labs_bilirubin", "donor_age", "donor_PHM",
        "donor_LVEF", "operative_IT_minutes", "operative_CPB_minutes",
        "postop_30_day_LVEF", "postop_ICU_LOS", "postop_hospital_LOS"
      )
    #- Define ordinal discrete variables
      ordinal_discrete <- c("recipient_UNOS_status")
  #+ Write a function to process each table appropriately according to the variable family it is in.
    analyze_table <- function(data, cont_vars, dichotomous_vars, dichotomous_nominal_vars, ordinal_vars) {
      data <- data %>% mutate(postop_PGD = recode(postop_PGD, "No" = "-PGD", "Yes" = "+PGD"))

      cont_vars <- cont_vars[cont_vars %in% colnames(data)]
      dichotomous_vars <- dichotomous_vars[dichotomous_vars %in% colnames(data)]
      dichotomous_nominal_vars <- dichotomous_nominal_vars[dichotomous_nominal_vars %in% colnames(data)]
      ordinal_vars <- ordinal_vars[ordinal_vars %in% colnames(data)]

      # ---- Continuous Variables ----
      continuous_results <- map_dfr(cont_vars, function(var) {
        group_stats <- data %>%
          group_by(postop_PGD) %>%
          summarise(Mean = mean(!!sym(var), na.rm = TRUE), SD = sd(!!sym(var), na.rm = TRUE), .groups = "drop")

        total_stats <- data %>%
          summarise(Mean = mean(!!sym(var), na.rm = TRUE), SD = sd(!!sym(var), na.rm = TRUE))

        if (nrow(group_stats) < 2) {
          return(NULL)
        }

        t_test_result <- t.test(data[[var]] ~ data$postop_PGD, na.action = na.omit)

        tibble(
          Variable = var,
          `-PGD` = sprintf("%.1f ± %.1f", group_stats$Mean[group_stats$postop_PGD == "-PGD"], group_stats$SD[group_stats$postop_PGD == "-PGD"]),
          `+PGD` = sprintf("%.1f ± %.1f", group_stats$Mean[group_stats$postop_PGD == "+PGD"], group_stats$SD[group_stats$postop_PGD == "+PGD"]),
          Total = sprintf("%.1f ± %.1f", total_stats$Mean, total_stats$SD),
          p_value = round(t_test_result$p.value, 3),
          sig = case_when(p_value < 0.001 ~ "***", p_value < 0.01 ~ "**", p_value < 0.05 ~ "*", TRUE ~ ""),
          Minority_Group = NA,
          Variable_Type = "Continuous"
        )
      })

      # ---- Ordinal Variables ----
      ordinal_results <- map_dfr(ordinal_vars, function(var) {
        group_stats <- data %>%
          group_by(postop_PGD) %>%
          summarise(
            Median = median(!!sym(var), na.rm = TRUE),
            IQR_low = quantile(!!sym(var), 0.25, na.rm = TRUE),
            IQR_high = quantile(!!sym(var), 0.75, na.rm = TRUE),
            .groups = "drop"
          )

        total_stats <- data %>%
          summarise(
            Median = median(!!sym(var), na.rm = TRUE),
            IQR_low = quantile(!!sym(var), 0.25, na.rm = TRUE),
            IQR_high = quantile(!!sym(var), 0.75, na.rm = TRUE)
          )

        if (nrow(group_stats) < 2) {
          return(NULL)
        }

        wilcox_result <- wilcox.test(data[[var]] ~ data$postop_PGD, na.action = na.omit, exact = FALSE)

        tibble(
          Variable = var,
          `-PGD` = sprintf(
            "%.1f [%.1f–%.1f]", group_stats$Median[group_stats$postop_PGD == "-PGD"],
            group_stats$IQR_low[group_stats$postop_PGD == "-PGD"],
            group_stats$IQR_high[group_stats$postop_PGD == "-PGD"]
          ),
          `+PGD` = sprintf(
            "%.1f [%.1f–%.1f]", group_stats$Median[group_stats$postop_PGD == "+PGD"],
            group_stats$IQR_low[group_stats$postop_PGD == "+PGD"],
            group_stats$IQR_high[group_stats$postop_PGD == "+PGD"]
          ),
          Total = sprintf("%.1f [%.1f–%.1f]", total_stats$Median, total_stats$IQR_low, total_stats$IQR_high),
          p_value = round(wilcox_result$p.value, 3),
          sig = case_when(p_value < 0.001 ~ "***", p_value < 0.01 ~ "**", p_value < 0.05 ~ "*", TRUE ~ ""),
          Minority_Group = NA,
          Variable_Type = "Ordinal"
        )
      })

      # ---- Dichotomous Variables ----
      dichotomous_results <- map_dfr(dichotomous_vars, function(var) {
        table_counts <- data %>%
          group_by(postop_PGD, !!sym(var)) %>%
          summarise(n = n(), .groups = "drop") %>%
          pivot_wider(names_from = !!sym(var), values_from = n, values_fill = list(n = 0))

        if (!all(c("Yes", "No") %in% colnames(table_counts))) {
          return(NULL)
        }

        fisher_result <- fisher.test(as.matrix(table_counts[, c("Yes", "No")]))

        tibble(
          Variable = paste0(var, "_No"),
          `-PGD` = sprintf("%d (%.1f%%)", table_counts$No[1], table_counts$No[1] / sum(table_counts[1, c("Yes", "No")]) * 100),
          `+PGD` = sprintf("%d (%.1f%%)", table_counts$No[2], table_counts$No[2] / sum(table_counts[2, c("Yes", "No")]) * 100),
          Total = sprintf("%d (%.1f%%)", sum(table_counts$No), sum(table_counts$No) / sum(table_counts[2:3]) * 100),
          p_value = round(fisher_result$p.value, 3),
          sig = case_when(p_value < 0.001 ~ "***", p_value < 0.01 ~ "**", p_value < 0.05 ~ "*", TRUE ~ ""),
          Minority_Group = NA,
          Variable_Type = "Dichotomous"
        )
      })

      summary_tibble <- bind_rows(continuous_results, ordinal_results, dichotomous_results) %>%
        arrange(Variable)

      return(summary_tibble)
    }
    analyze_table_multinomial <- function(data, multinomial_vars) {
      # Filter only multinomial variables that exist in the dataset
      multinomial_vars <- multinomial_vars[multinomial_vars %in% colnames(data)]

      #- Process Multinomial Variables ----
      multinomial_results <- map_dfr(multinomial_vars, function(var) {
        if (!var %in% colnames(data)) {
          return(NULL)
        }

        # Perform Fisher's exact test
        fisher_result <- fisher.test(table(data[[var]], data$postop_PGD))

        # Create a count table
        table_data <- data %>%
          group_by(postop_PGD, !!sym(var)) %>%
          summarise(n = n(), .groups = "drop") %>%
          pivot_wider(names_from = !!sym(var), values_from = n, values_fill = list(n = 0)) %>%
          pivot_longer(cols = -postop_PGD, names_to = "Category", values_to = "Count") %>%
          mutate(Percent = Count / sum(Count, na.rm = TRUE) * 100) %>%
          mutate(Formatted = sprintf("%d (%.1f%%)", Count, Percent))

        if (nrow(table_data) == 0) {
          return(NULL)
        }

        # Format output
        table_data %>%
          mutate(
            Variable = var,
            p_value = round(fisher_result$p.value, 3),
            sig = case_when(
              p_value < 0.001 ~ "***",
              p_value < 0.01 ~ "**",
              p_value < 0.05 ~ "*",
              TRUE ~ ""
            ),
            Variable_Type = "Multinomial"
          ) %>%
          select(Variable, Category, `-PGD` = Formatted, `+PGD` = Formatted, p_value, sig, Variable_Type)
      })

      return(multinomial_results)
    }
    #! Need to update median 
#* Table 1: Recipient Characteristics
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
#* Table 2: Donor Characteristics
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
#* Table 3: Periop and Outcomes
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