

# Source custom network preparation function
source("../Utilities/Analysis/build_network.R")


# Create output directories for MetaboAnalystR results
dir.create("../../Outputs/mummichog/outputs", showWarnings = FALSE, recursive = TRUE)
dir.create("../../Outputs/mummichog/outputs/nosev", showWarnings = FALSE, recursive = TRUE)
dir.create("../../Outputs/mummichog/outputs/nosev/MFN", showWarnings = FALSE, recursive = TRUE)

# Store original working directory
original_wd <- getwd()

# MFN Analysis
cat("Running MFN analysis...\n")
setwd("../../Outputs/mummichog/outputs/nosev/MFN")

mSet_mfn <- InitDataObjects("mass_all", "mummichog", FALSE, 150) %>%
  SetPeakFormat("rmp") %>%
  UpdateInstrumentParameters(5.0, "mixed", "yes", 0.02) %>%
  Read.PeakListData("../../../../mummichog/inputs/nosev.csv") %>%
  SanityCheckMummichogData() %>%
  SetPeakEnrichMethod("mum", "v2") %>%
  SetMummichogPval(0.1) %>%
  PerformPSEA("hsa_mfn", "current", 3, 100) %>%
  PlotPeaks2Paths("metaboanalyst_mfn_", "png", 150, width=NA)

# Custom network preparation (bypasses missing compiled components)
tryCatch({
  mSet_mfn <- prepare_custom_enrichnet(mSet_mfn, "enrichNet_mfn", "mixed")
  cat("✓ Custom network analysis prepared for MFN\n")
}, error = function(e) {
  cat("⚠ Custom network analysis failed for MFN:", e$message, "\n")
})

setwd(original_wd)  # Return to original directory

cat("✓ MFN analysis complete!\n")
cat("Results saved in: Outputs/mummichog/outputs/nosev/MFN/\n")