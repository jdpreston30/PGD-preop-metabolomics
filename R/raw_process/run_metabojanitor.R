#! Updated function on 9/30 to use Combat FT and reran here
# ! New version also got rid of mzm entirely and the Simple/ folder
#+ Setup
#- MAC MINI Paths
raw_path <- "/Users/JoshsMacbook2015/Library/CloudStorage/OneDrive-EmoryUniversity/Research/MS_raw_data/Chan_studies_MS_raw/PGD_studies/Chan_PGD_9_2025"
output_dir <- "/Users/JoshsMacbook2015/Library/CloudStorage/OneDrive-EmoryUniversity/Research/MS_raw_data/Chan_studies_MS_raw/PGD_studies/Chan_PGD_9_2025/MetaboJanitoR"
#- LAPTOP Paths
raw_path <- "/Users/jdp2019/Library/CloudStorage/OneDrive-Emory/Research/MS_raw_data/Chan_studies_MS_raw/PGD_studies/Chan_PGD_9_2025"
output_dir <- "/Users/jdp2019/Library/CloudStorage/OneDrive-Emory/Research/MS_raw_data/Chan_studies_MS_raw/PGD_studies/Chan_PGD_9_2025/MetaboJanitoR"
#- Install if needed
remove.packages("MetaboJanitoR")
remotes::install_github("jdpreston30/MetaboJanitoR", force = TRUE)
#- Load
library(MetaboJanitoR)
#+ Run with global
run_metabo_janitor(
  raw_path,
  output_dir,
  msmica_kegg_iterations = c("G"),
  prompt_timeout = 3,
  use_ComBat_FT = TRUE
)
#+ Notes
# ! H14S2 did not have C18- run for some reason, missing the following samples:
# ! VT_250824_M623_098, VT_250824_M623_100, VT_250824_M623_102
# ! So, used the full (available HILIC + full C18) for MSMICA annotation, but had missing HILIC removed from final FTs
# ! Total removed: VT_250824_M623_097, VT_250824_M623_098, VT_250824_M623_099, VT_250824_M623_100, VT_250824_M623_101, VT_250824_M623_102
# ! Thus, H14S2 HILIC and C18 is NOT present in final output FTs