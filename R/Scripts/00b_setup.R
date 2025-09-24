#* 0b: Configuration Setup
#+ 0b.1: Set up R options and repositories
  options(repos = c(CRAN = "https://cran.rstudio.com/"))
  options(expressions = 10000)
#+ 0b.2: Essential packages (loaded by 0a_environment_setup.R)
  # yaml and here are already loaded
#+ 0b.3: Load project configuration
  #- 0b.3.1: Read YAML configuration
    config <- yaml::read_yaml(here::here("config.yaml"))
    # config <- yaml::read_yaml(here::here("config_AT.yaml"))
  #- 0b.3.2: Make config available globally (for compatibility)
    .GlobalEnv$CONFIG <- config
#+ 0b.4: Set up global paths from config
  raw_path <- config$paths$raw_data
  output_path <- config$paths$output  
  scripts_path <- config$paths$scripts
  utils_path <- config$paths$utils
#+ 0b.5: Create output directory if it doesn't exist
  if (!dir.exists(output_path)) {
    dir.create(output_path, recursive = TRUE)
    cat("📁 Created output directory:", output_path, "\n")
  }
#+ 0b.6: Set up R environment preferences
  #- 0b.6.1: Tibble preferences
    options(
      tibble.print_max = config$analysis$tibble_options$print_max,
      tibble.print_min = config$analysis$tibble_options$print_min,
      pillar.sigfig = config$analysis$tibble_options$sigfig
    )
  #- 0b.6.2: Data.table preferences
    if (!is.null(config$analysis$datatable_options)) {
      options(
        datatable.print.class = config$analysis$datatable_options$print_class,
        datatable.print.keys = config$analysis$datatable_options$print_keys
      )
      .datatable.aware = config$analysis$datatable_options$aware
    }
#+ 0b.7: Set up package conflict preferences
  # conflicted is already loaded by 0a_environment_setup.R
  conflicts_prefer(purrr::map)
  conflicts_prefer(dplyr::filter) 
  conflicts_prefer(dplyr::select)
  conflicts_prefer(stats::chisq.test)
#+ 0b.8: Load utility functions
  if (dir.exists(utils_path)) {
    purrr::walk(
      list.files(utils_path, pattern = "\\.[rR]$", full.names = TRUE, recursive = TRUE),
      source
    )
    cat("🔧 Loaded utility functions\n")
  }
  cat("✅ Configuration and environment setup complete!\n")
