#* 00b: Configuration Setup
#+ 00b.1: Set up R options and repositories
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
  options(expressions = 10000)
#+ 00b.2: Load essential packages for configuration
  #- 00b.2.1: Install yaml and here if missing
    if (!require(yaml, quietly = TRUE)) install.packages("yaml")
    if (!require(here, quietly = TRUE)) install.packages("here")
    library(yaml)
    library(here)
#+ 00b.3: Load project configuration  
  #- 00b.3.1: Read YAML configuration
    config <- yaml::read_yaml(here::here("config.yaml"))
  #- 00b.3.2: Make config available globally (for compatibility)
    .GlobalEnv$CONFIG <- config
#+ 00b.4: Set up global paths from config
  raw_path <- config$paths$raw_data
  output_path <- config$paths$output  
  scripts_path <- config$paths$scripts
  utils_path <- config$paths$utils
#+ 00b.5: Create output directory if it doesn't exist
  if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
    cat("📁 Created output directory:", output_path, "\n")
  }
#+ 00b.6: Set up R environment preferences
  #- 00b.6.1: Tibble preferences
    options(
      tibble.print_max = config$analysis$tibble_options$print_max,
      tibble.print_min = config$analysis$tibble_options$print_min,
      pillar.sigfig = config$analysis$tibble_options$sigfig
    )
  #- 00b.6.2: Data.table preferences
    if (!is.null(config$analysis$datatable_options)) {
      options(
        datatable.print.class = config$analysis$datatable_options$print_class,
        datatable.print.keys = config$analysis$datatable_options$print_keys
      )
      .datatable.aware = config$analysis$datatable_options$aware
    }
#+ 00b.7: Set up package conflict preferences
  library(conflicted)
  conflicts_prefer(purrr::map)
  conflicts_prefer(dplyr::filter) 
  conflicts_prefer(dplyr::select)
#+ 00b.8: Load utility functions
  if (dir.exists(utils_path)) {
    purrr::walk(
      list.files(utils_path, pattern = "\\.[rR]$", full.names = TRUE, recursive = TRUE),
      source
    )
    cat("🔧 Loaded utility functions\n")
  }
  cat("✅ Configuration and environment setup complete!\n")
