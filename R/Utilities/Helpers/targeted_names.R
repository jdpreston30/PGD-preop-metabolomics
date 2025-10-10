#' Metabolite Name Mapping for Targeted Analysis
#'
#' A named character vector providing standardized, publication-ready names for
#' targeted metabolomics features. Maps from original feature names (names) to
#' preferred display names (values).
#'
#' @format A named character vector with original names as names and preferred names as values
#'
#' @details
#' This mapping provides several types of name standardization:
#' - Chemical nomenclature standardization (e.g., D-Ribose -> Ribose)
#' - Greek letter formatting (e.g., 4-Trimethylammoniobutanoate -> γ-Butyrobetaine)
#' - Consistent abbreviation usage (e.g., AMP -> Adenosine Monophosphate)
#' - Simplified display names for complex chemical names
#' - Asterisks (*) indicate metabolites with potential annotation ambiguity
#'
#' @examples
#' \dontrun{
#'   # Apply name mapping to metabolite data
#'   metabolite_data$display_name <- name_map[metabolite_data$original_name]
#'   
#'   # Get preferred name for a specific metabolite
#'   preferred_name <- name_map["4-Methyl-2-oxopentanoate"]
#'   # Returns: "α-Ketoisocaproate*"
#' }
#'
#' @export
name_map <- c(
  "Lovastatin acid"                  = "Lovastatin acid",
  "D-Ribose"                         = "Ribose",
  "Digitalose"                       = "Digitalose",
  "4-Trimethylammoniobutanoate"      = "γ-Butyrobetaine",
  "N-Acetyl-D-glucosaminate"         = "N-Acetylglucosamine",
  "L-Homocysteine"                   = "Homocysteine",
  "Linoleate"                        = "Linoleic Acid",
  "AMP"                              = "Adenosine Monophosphate",
  "6-Hydroxyhexanoic acid"           = "6-Hydroxycaproic Acid",
  "L-Tyrosine methyl ester"          = "Tyrosine Methyl Ester",
  "Methylimidazole acetaldehyde"     = "Methylimidazole Acetaldehyde",
  "3beta,7alpha-Dihydroxy-5-cholestenoate" = "3β,7α-Dihydroxycholestenoate",
  "4-Methyl-2-oxopentanoate"         = "α-Ketoisocaproate*",
  "9,10-Epoxystearate"               = "Epoxystearate*",
  "Deglymidodrine"                   = "Desglymidodrine",
  "N-Acetyl-L-leucine"               = "N-Acetylleucine",
  "(S)-2-Aminobutanoate"             = "2-Aminobutanoate",
  "N-Methylethanolamine phosphate"   = "Monomethylethanolamine Phosphate",
  "1-Pyrroline-4-hydroxy-2-carboxylate" = "4-Hydroxy-2-carboxy-1-pyrroline",
  "L-Glutamyl 5-phosphate"           = "Glutamyl-5-Phosphate",
  "5-Aminopentanamide"               = "5-Aminovaleramide",
  "o-Benzoquinone"                   = "o-Benzoquinone",
  "Hydroxylaminobenzene"             = "Phenylhydroxylamine",
  "Gentisate aldehyde"               = "Gentisaldehyde",
  "2-Aceto-2-hydroxybutanoate"       = "2-Hydroxy-2-oxobutanoate",
  "Erythrulose 1-phosphate"          = "Erythrulose-1-Phosphate",
  "4-Hydroxy-4-methyl-2-oxoadipate"  = "4-Hydroxy-4-methyl-2-oxoadipate",
  "3-Methyl-2-oxobutanoic acid"      = "α-Ketoisovalerate*",
  "4-Amino-5-hydroxymethyl-2-methylpyrimidine" = "Thiamine Pyrimidine*",
  "4-Pyridoxolactone"                = "Pyridoxolactone",
  "Pyridoxamine"                     = "Pyridoxamine"
)
