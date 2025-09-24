#* Pipeline Runner for Academic Publication
#* Run Analysis Pipeline
#+ Setup environment and configuration
  {invisible(sapply(c("R/Scripts/00a_environment_setup.R", "R/Scripts/00b_setup.R"), source))
#+ Run analysis scripts
  source("R/Scripts/00c_clinical_metadata.R")
  source("R/Scripts/00d_FTs.R")
  source("R/Scripts/01_clustering.R")}



config <- yaml::read_yaml(here::here("config.yaml"))
