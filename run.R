#* Run Analysis Pipeline
#+ Setup environment and configuration
source("R/Utilities/Helpers/load_dynamic_config.R")
#- For ComBat Corrected Run
config <- load_dynamic_config(computer = "auto", config_path = "config_dynamic.yaml")
#- For 3b Run
config <- load_dynamic_config(computer = "auto", config_path = "config_dynamic_3b.yaml")
#- Run Pipeline
{
source("R/Scripts/00a_environment_setup.R")
source("R/Scripts/00b_setup.R")
source("R/Scripts/00c_clinical_metadata.R")
source("R/Scripts/00d_FTs.R")
source("R/Scripts/01_clustering.R")
source("R/Scripts/02_pathway_enrich.R")
source("R/Scripts/03a_annotated_bars.R")
source("R/Scripts/03b_targeted_bars.R")
source("R/Scripts/04_tables.R")
source("R/Scripts/05_assign_plots.R")
source("R/Scripts/06_render_figures.R")
source("R/Scripts/07_data_not_shown.R")
}
