#* Run Analysis Pipeline
#+ Setup environment and configuration
#- Select YAML
config <- yaml::read_yaml(here::here("config.yaml"))
config <- yaml::read_yaml(here::here("config_AT.yaml"))
#- Run Scripts 
{source("R/Scripts/00a_environment_setup.R")
source("R/Scripts/00b_setup.R")}
#+ Imports and Preprocess
{source("R/Scripts/00c_clinical_metadata.R")
source("R/Scripts/00d_FTs.R")}
#+ Analysis
#- Main Analysis
source("R/Scripts/01_clustering.R")
source("R/Scripts/02_pathway_enrich.R")
source("R/Scripts/03_targeted_bars.R")
source("R/Scripts/04_tables.R")
#- Visualization
# source("R/Scripts/05_figures.R")
#- Data Note Shown
source("R/Scripts/06_data_not_shown.R")
#+

source("R/Scripts/01_clustering.R")

{
  source("R/Scripts/00b_setup.R")
  source("R/Scripts/05_create_plots.R")
  source("R/Scripts/06_render_figures.R")
}







# {
#   source("R/Scripts/00a_environment_setup.R")
#   source("R/Scripts/00b_setup.R")
#   source("R/Scripts/00c_clinical_metadata.R")
#   source("R/Scripts/00d_FTs.R")
#   source("R/Scripts/01_clustering.R")
#   source("R/Scripts/05_create_plots.R")
#   source("R/Scripts/06_render_figures.R")
# }
