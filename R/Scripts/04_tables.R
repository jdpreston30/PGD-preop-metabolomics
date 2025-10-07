#* 4: Create Tables
#+ 4.0a: Examine Normality
#! Did manual examination of this via below TernTables runs
#! T1 has 12/16 normality fail, T2 has 2/3, and T3 has 7/10
#! But, just going to use consider normality = TRUE to do test dynamically
#+ 4.0b: Set Conflicts
conflicts_prefer(purrr::compose)
#+ 4.1: Table 1 (Recipient Preoperative Characteristics) 
T1 <- ternG(
  data = T1_data,
  exclude_vars = "Patient",
  group_var = "severe_PGD",
  descriptive = TRUE,
  output_docx = "Outputs/Tables/T1.docx",
  consider_normality = TRUE
)
#+ 4.2: Table 2 (Donor Characteristics) 
T2 <- ternG(
  data = T2_data,
  vars = NULL,
  exclude_vars = "Patient",
  group_var = "severe_PGD",
  descriptive = TRUE,
  output_docx = "Outputs/Tables/T2.docx",
  consider_normality = TRUE
)
#+ 4.3: Table 3 (Table 3. Procurement/Surgical Factors and Perioperative/Post-Transplant Outcomes) 
T3 <- ternG(
  data = T3_data,
  vars = NULL,
  exclude_vars = "Patient",
  group_var = "severe_PGD",
  descriptive = TRUE,
  output_docx = "Outputs/Tables/T3.docx",
  consider_normality = TRUE
)
