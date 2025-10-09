read_mummichog_json <- function(file_path) {
  dat <- fromJSON(file_path)
  tibble(
    pathway = dat$pathnames,
    enrichment = dat$enr,
    p_value = dat$pval
  )
}
