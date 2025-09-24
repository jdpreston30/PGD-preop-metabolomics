#* Run Analysis Pipeline
#+ Setup environment and configuration----
#- Select YAML----
config <- yaml::read_yaml(here::here("config.yaml"))
config <- yaml::read_yaml(here::here("config_AT.yaml"))
#- Run Scripts----
{source("R/Scripts/00a_environment_setup.R")
source("R/Scripts/00b_setup.R")}
#+ Imports and Preprocess----
{source("R/Scripts/00c_clinical_metadata.R")
source("R/Scripts/00d_FTs.R")}
#+ Analysis----
source("R/Scripts/01_clustering.R")
#+ Visualization----