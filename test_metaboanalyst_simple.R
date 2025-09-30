library(MetaboAnalystR)

# MFN Analysis
cat("Running MFN analysis...\n")
mSet_mfn <- InitDataObjects("mass_all", "mummichog", FALSE, 150)
mSet_mfn <- SetPeakFormat(mSet_mfn, "rmp")
mSet_mfn <- UpdateInstrumentParameters(mSet_mfn, 5.0, "mixed", "yes", 0.02)
mSet_mfn <- Read.PeakListData(mSet_mfn, "Outputs/mummichog/inputs/nosev.csv")
mSet_mfn <- SanityCheckMummichogData(mSet_mfn)
mSet_mfn <- SetPeakEnrichMethod(mSet_mfn, "mum", "v2")
mSet_mfn <- SetMummichogPval(mSet_mfn, 0.1)
mSet_mfn <- PerformPSEA(mSet_mfn, "hsa_mfn", "current", 3, 100)
mSet_mfn <- PlotPeaks2Paths(mSet_mfn, "metaboanalyst_mfn_", "png", 150, width=NA)
mSet_mfn <- PrepareEnrichNet(mSet_mfn, "enrichNet_mfn", "mixed", "mum")

# Rename MFN results files
if(file.exists("mummichog_pathway_enrichment_mummichog.csv")) {
  file.rename("mummichog_pathway_enrichment_mummichog.csv", "mummichog_pathway_enrichment_MFN.csv")
  file.rename("mummichog_matched_compound_all.csv", "mummichog_matched_compound_MFN.csv")
}

cat("MFN analysis complete.\n")

# KEGG Analysis  
cat("Running KEGG analysis...\n")
mSet_kegg <- InitDataObjects("mass_all", "mummichog", FALSE, 150)
mSet_kegg <- SetPeakFormat(mSet_kegg, "rmp")
mSet_kegg <- UpdateInstrumentParameters(mSet_kegg, 5.0, "mixed", "yes", 0.02)
mSet_kegg <- Read.PeakListData(mSet_kegg, "Outputs/mummichog/inputs/nosev.csv")
mSet_kegg <- SanityCheckMummichogData(mSet_kegg)
mSet_kegg <- SetPeakEnrichMethod(mSet_kegg, "mum", "v2")
mSet_kegg <- SetMummichogPval(mSet_kegg, 0.1)
mSet_kegg <- PerformPSEA(mSet_kegg, "hsa_kegg", "current", 3, 100)
mSet_kegg <- PlotPeaks2Paths(mSet_kegg, "metaboanalyst_kegg_", "png", 150, width=NA)
mSet_kegg <- PrepareEnrichNet(mSet_kegg, "enrichNet_kegg", "mixed", "mum")

# Rename KEGG results files
if(file.exists("mummichog_pathway_enrichment_mummichog.csv")) {
  file.rename("mummichog_pathway_enrichment_mummichog.csv", "mummichog_pathway_enrichment_KEGG.csv")
  file.rename("mummichog_matched_compound_all.csv", "mummichog_matched_compound_KEGG.csv")
}

cat("KEGG analysis complete.\nResults saved in mSet_mfn and mSet_kegg objects.\n")