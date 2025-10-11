#! This was just basic troubleshooting trying to determine the difference between cluster I an II on the PCA, which came down to amio
pca_data_meta <- uft_pca$scores_df %>%
  mutate(PC1 = if_else(Comp1 > 25, "High", "Low")) %>%
  arrange(PC1) %>%
  select(Patient, PC1) %>%
  left_join(clinical_metadata_i, by = "Patient") %>%
  as_tibble() %>%
  select(-starts_with("donor_")) %>%
  select(-ISHLT_Chan_disagreement, -postop_PGD_Chan) %>%
  select(-c(postop_PGD_textbook_calc:Last)) %>%
  select(-c(operative_surgery_start:operative_DT_off_CPB)) %>%
  select(-c(preop_PVR_date, preop_sample_date, preop_admit_date, operative_transplant_date, preop_temp_MCS_details, preop_MCS_details, Patient_DOB, recipient_etiology_email)) %>%
  mutate(PC1 = as.factor(PC1)) %>%
  mutate(across(where(is.character), as.factor))


library(TernTablesR)
results <- ternG(
  data = pca_data_meta,
  vars = NULL,
  exclude_vars = "Patient",
  group_var = "postop_PGD_ISHLT",
  descriptive = FALSE,
  consider_normality = TRUE,
  print_normality = FALSE
) %>%
  arrange(p)
# #+ 1.5: PCA Loadings Analysis - Top Contributors with Named Metabolites


#   tft_pca <- make_PCA(TFT_annot, method = "PCA", show_patient_labels = TRUE, label_size = 2)
#   print(tft_pca$plot)




#   cat("\n=== TOP LOADINGS CONTRIBUTING TO PC SEPARATION ===\n")

#   # Extract loadings for PC1 and PC2
#   pc1_loadings <- tft_pca$model$rotation[, 1]
#   pc2_loadings <- tft_pca$model$rotation[, 2]

#   # Create dataframes for PC1 top and bottom contributors
#   pc1_top_positive_df <- data.frame(
#     Feature = names(head(sort(pc1_loadings, decreasing = TRUE), 10)),
#     PC1_Loading = head(sort(pc1_loadings, decreasing = TRUE), 10),
#     Direction = "Positive"
#   ) %>%
#     left_join(TFT_annot_key, by = "Feature") %>%
#     select(Feature, PC1_Loading, Direction, `Identified Name`, Name, everything())

#   pc1_top_negative_df <- data.frame(
#     Feature = names(head(sort(pc1_loadings, decreasing = FALSE), 10)),
#     PC1_Loading = head(sort(pc1_loadings, decreasing = FALSE), 10),
#     Direction = "Negative"
#   ) %>%
#     left_join(TFT_annot_key, by = "Feature") %>%
#     select(Feature, PC1_Loading, Direction, `Identified Name`, Name, everything())

#   # Combine PC1 contributors
#   pc1_contributors <- bind_rows(pc1_top_positive_df, pc1_top_negative_df) %>%
#     arrange(desc(abs(PC1_Loading)))

#   # Create dataframes for PC2 top and bottom contributors
#   pc2_top_positive_df <- data.frame(
#     Feature = names(head(sort(pc2_loadings, decreasing = TRUE), 10)),
#     PC2_Loading = head(sort(pc2_loadings, decreasing = TRUE), 10),
#     Direction = "Positive"
#   ) %>%
#     left_join(TFT_annot_key, by = "Feature") %>%
#     select(Feature, PC2_Loading, Direction, `Identified Name`, Name, everything())

#   pc2_top_negative_df <- data.frame(
#     Feature = names(head(sort(pc2_loadings, decreasing = FALSE), 10)),
#     PC2_Loading = head(sort(pc2_loadings, decreasing = FALSE), 10),
#     Direction = "Negative"
#   ) %>%
#     left_join(TFT_annot_key, by = "Feature") %>%
#     select(Feature, PC2_Loading, Direction, `Identified Name`, Name, everything())

#   # Combine PC2 contributors
#   pc2_contributors <- bind_rows(pc2_top_positive_df, pc2_top_negative_df) %>%
#     arrange(desc(abs(PC2_Loading)))

#   # Display results
#   cat("PC1 TOP CONTRIBUTORS (with metabolite names):\n")
#   print(pc1_contributors %>% select(Feature, PC1_Loading, Direction, `Identified Name`))

#   cat("\nPC2 TOP CONTRIBUTORS (with metabolite names):\n")
#   print(pc2_contributors %>% select(Feature, PC2_Loading, Direction, `Identified Name`))
