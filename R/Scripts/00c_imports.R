#* 00c: Importing data
#+ 00c.1: Feature tables
  TFT <- read_csv(config$paths$TFT)
  UFT <- read_csv(config$paths$UFT_full)
  UFT_filtered <- read_csv(config$paths$UFT_filtered)
#+ 00c.2: Clinical metadata
  preop <- read_xlsx(config$paths$clinical_metadata, sheet = "Preop")