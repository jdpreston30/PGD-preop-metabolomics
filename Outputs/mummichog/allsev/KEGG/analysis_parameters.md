# Mummichog Analysis Parameters

**Analysis Date:** 2025-10-03

**Database:** hsa_kegg

**MetaboAnalystR 'Set' Function Outputs:**
- SetPeakFormat: mpr
- SetPeakEnrichMethod: mummichog (v2)
- SetMummichogPvalFromPercent: 0.1 (top 10% of peaks)

**Instrument Parameters (UpdateInstrumentParameters):**
- instrumentOpt: 5
- msModeOpt: mixed
- force_primary_ion: yes
- rt_frac: 0.02

**Analysis Parameters:**
- Peak filtering method: Top 10% of peaks (dynamic)
- Peak filtering threshold (rounded): 0.1
- Peak filtering threshold (precise): 0.110383730422262
- Peaks analyzed: 552 out of 25051
- Pathways analyzed: 62
- Significant pathways (p < 0.05): 3
- Pathway p-values range: 0.013282 to 0.99935
- Pathway FDR: Not calculated (using raw p-values)
- Pathway enrichment FDR threshold: 0.05 (fixed)
- Minimum pathway size: 3
- Background permutations: 100

**Input Data:**
- Number of features: 25051
- Output directory: Outputs/mummichog/allsev/KEGG

