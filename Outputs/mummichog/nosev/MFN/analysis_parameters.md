# Mummichog Analysis Parameters

**Analysis Date:** 2025-10-01

**Database:** hsa_mfn

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
- Peak filtering threshold (precise): 0.131209719008776
- Peaks analyzed: 856 out of 25051
- Pathways analyzed: 83
- Significant pathways (p < 0.05): 4
- Pathway p-values range: 0.000932 to 0.97944
- Pathway FDR: Not calculated (using raw p-values)
- Pathway enrichment FDR threshold: 0.05 (fixed)
- Minimum pathway size: 3
- Background permutations: 100

**Input Data:**
- Number of features: 25051
- Output directory: Outputs/mummichog/nosev/MFN

