#' Metabolites to Exclude from Targeted Analysis
#'
#' A curated list of metabolite names to exclude from targeted metabolomics analysis.
#' These metabolites are primarily xenobiotics, food components, bacterial metabolites,
#' pharmaceuticals, and plant metabolites that may not be relevant for human endogenous
#' metabolism studies or may represent annotation artifacts.
#'
#' @format A character vector with 53 metabolite names
#'
#' @details
#' The excluded metabolites fall into several categories:
#' - Xenobiotics: External chemical compounds
#' - Food components: Dietary-derived metabolites
#' - Bacterial metabolites: Compounds of microbial origin
#' - Plant metabolites: Phytochemicals and plant-derived compounds
#' - Pharmaceuticals: Drug compounds and their metabolites
#' - Antibiotics: Antibiotic compounds and components
#' - Fungicides/Herbicides: Agricultural chemicals
#'
#' Note: L-Rhamnose appears in both analytical modes, so this list of 53 names
#' will exclude 54 total metabolite features.
#'
#' @source Curated by CJR research team for PGD metabolomics analysis
#'
#' @examples
#' \dontrun{
#'   # Filter out excluded metabolites from analysis
#'   filtered_data <- metabolite_data %>%
#'     filter(!metabolite_name %in% exclude_metabolites)
#' }
#'
#' @export
#- Create custom list of feature names to exclude per CJR research
#! Most all these are xenobiotics, food components, bacterial metabolites, and may be not relevant at best or bad annotations at worst
exclude_metabolites <- c(
  "(3S)-2-Oxo-3-phenylbutanoate",           # Xenobiotic
  "Sordaricin",                             # Fungal metabolite
  "3-O-alpha-Mycarosylerythronolide B",     # Antibiotic
  "Falcarinol",                             # Plant metabolite
  "Hapalindole G",                          # Cyanobacterial metabolite
  "12-epi-Fischerindole G",                 # Cyanobacterial metabolite
  "4-Amino-4-deoxy-L-arabinose",            # Bacterial metabolite
  "Capsiate",                               # Plant metabolite
  "Mytatrienediol",                         # Bacterial metabolite
  "(2S)-2-Isopropyl-3-oxosuccinate",       # Xenobiotic
  "L-Histidinal",                           # Bacterial metabolite
  "Echinenone",                             # Carotenoid (bacterial/plant)
  "Hydroxychlorobactene",                   # Bacterial metabolite
  "Cucurbitacin E",                         # Plant metabolite
  "Tremetone",                              # Plant toxin
  "2 -(Butylamido)-4-hydroxybutanoic acid", # Xenobiotic
  "Uplandicine",                            # Plant alkaloid
  "N-Acetyl-L-glutamate 5-semialdehyde",   # Bacterial metabolite
  "6-Acetamido-2-oxohexanoate",            # Bacterial metabolite
  "Swainsonine",                            # Plant alkaloid/toxin
  "cis-1,2-Dihydronaphthalene-1,2-diol",   # Xenobiotic
  "3-Methylindolepyruvate",                 # Bacterial metabolite
  "4-Hydroxybenzaldehyde",                  # Food component
  "Hydroxymethylphosphonate",               # Xenobiotic
  "Fentin acetate",                         # Fungicide
  "Benzene-1,2,4-triol",                   # Xenobiotic
  "Piperidine",                             # Chemical intermediate
  "2-Nitrophenol",                          # Xenobiotic
  "4-Oxocyclohexanecarboxylate",           # Xenobiotic
  "Vanillyl alcohol",                       # Food component
  "(3,4-Dimethoxyphenyl)methanol",         # Food component
  "Dihydrocoumarin",                        # Plant metabolite
  "Bornyl isovalerate",                     # Plant metabolite
  "4-Hydroxyphthalate",                     # Xenobiotic
  "4-Hydroxyphenacyl alcohol",              # Xenobiotic
  "Chrysanthemol",                          # Plant metabolite
  "Bromobenzene-3,4-oxide",                # Xenobiotic
  "Bromobenzene-2,3-oxide",                # Xenobiotic
  "(R)-2,3-Dihydroxypropane-1-sulfonate",  # Xenobiotic
  "Isocil",                                 # Herbicide
  "Ethylendiamine dihydroiodide",          # Chemical
  "34a-Deoxy-rifamycin W",                 # Antibiotic
  "L-Rhamnose",                             # Plant sugar (duplicate entry)
  "Dexamethasone acetate anhydrous",       # Pharmaceutical
  "Nigakilactone H",                        # Plant metabolite
  "Streptamine",                            # Antibiotic component
  "Zaluzanin C",                            # Plant metabolite
  "4-Hydroxybenzoyl-adenylate",            # Xenobiotic
  "4'-Methoxyisoflavone",                  # Plant metabolite
  "S-(Indolylmethylthiohydroximoyl)-L-cysteine", # Plant metabolite
  "Nafenopin glucuronide",                  # Drug metabolite
  "Istamycin C",                            # Antibiotic
  "Jasmolin II"                             # Plant metabolite/insecticide
)
#! L-Rhamnose was detected in both modes so this list is 53 long but will exclude 54 total metabolites