#' Install GitHub packages if missing
#' @param github_info List with repo and package name
#' @param force_reinstall Logical, whether to force reinstall
#' @return NULL (installs package if missing)
install_github_if_missing <- function(github_info, force_reinstall = FALSE) {
  # check if github package is missing
  package_name <- github_info$package
  github_repo <- github_info$repo

  if (!package_name %in% installed.packages()[, "Package"] || force_reinstall) {
    cat("Installing", package_name, "from GitHub...\n")
    remotes::install_github(github_repo, force = force_reinstall)
  } else {
    cat(package_name, "is already installed.\n")
  }
}