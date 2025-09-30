# Mummichog Analysis Parameters

**Analysis Date:** 2025-09-30

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
- Peak filtering p-value threshold (calculated): 0.1
- Pathway enrichment p-value threshold: 0.05 (fixed)
- Minimum pathway size: 3
- Permutations for background: 100

**Input Data:**
- Number of features: 25051
- Output directory: Outputs/mummichog/nosev/MFN

