#* 0d: Importing feature tables and preprocessing
#+ 0d.0: Pull PGD info ----
pgd_status <- clinical_metadata_i %>%
  select(Patient, PGD = postop_PGD_ISHLT)
#+ 0d.1:Import FTs, add Patient and Sample IDs, filter to S0 (preop) ----
TFT <- read_csv(config$paths$TFT) %>%
  preprocess_FT()
UFT <- read_csv(config$paths$UFT_full) %>%
  preprocess_FT()
UFT_filtered <- read_csv(config$paths$UFT_filtered) %>%
  preprocess_FT()
#! Filtering out H49 as this was a 'false start' where we collected early but then heart offer didn't go through
#! Fixed typo in Sample_ID for H46SS0
#+ 0d.2: Import MSMICA feature key ----
TFT_key <- read_csv(config$paths$TFT_key)
