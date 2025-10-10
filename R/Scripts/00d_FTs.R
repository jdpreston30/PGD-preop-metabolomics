#* 0d: Importing feature tables and preprocessing
#+ 0d.0: Pull PGD info 
pgd_status <- clinical_metadata_i %>%
  select(Patient, PGD = postop_PGD_ISHLT)
#+ 0d.1:Import FTs, add Patient and Sample IDs, filter to S0 (preop) 
TFT_annot <- read_csv(config$paths$TFT_annot) %>%
  preprocess_FT()
UFT <- read_csv(config$paths$UFT_full) %>%
  preprocess_FT()
UFT_filtered <- read_csv(config$paths$UFT_filtered) %>%
  preprocess_FT()
#! Filtering out H49 as this was a 'false start' where we collected early but then heart offer didn't go through
#! Fixed typo in Sample_ID for H46SS0
#+ 0d.2: Import MSMICA feature key 
TFT_key <- read_csv(config$paths$TFT_key)
#+ 0d.3: Bring in IROA IDX feature library
qstd_c18 <- read_tsv(config$paths$qstd_c18) %>%
  mutate(lib = "C18")
qstd_hilic <- read_tsv(config$paths$qstd_hilic) %>%
  mutate(lib = "HILIC")
qstd_quant <- bind_rows(qstd_c18, qstd_hilic)
idx_lib <- read_csv(config$paths$idx_library)  
#+ 0d.4: Create Identified TFT_confirmed based on library
identified <- create_identified_FT(
  feature_table = UFT_filtered,
  reference_library = idx_lib,
  mz_thresh_ppm = 5,
  time_thresh_sec = 30
)
TFT_confirmed <- identified$TFT_confirmed
TFT_confirmed_key <- identified$matched_features %>%
  select(Feature = feature, `Identified Name` = compound_name, Isomer = library_isomer, everything()) %>%
  mutate(`Multi-Mode Detection` = "")
  
