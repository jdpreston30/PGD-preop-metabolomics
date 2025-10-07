#' Load and resolve dynamic configuration based on computer
#'
#' @param computer Character string: "laptop", "desktop", or "auto" for auto-detection
#' @param config_path Path to the YAML configuration file
#' @return Resolved configuration list with substituted paths
#' @export
load_dynamic_config <- function(computer = "auto", config_path = "config_dynamic.yaml") {
  # Load raw configuration
  raw_config <- yaml::read_yaml(here::here(config_path))
  
  # Auto-detect computer if requested
  if (computer == "auto") {
    current_user <- Sys.getenv("USER")
    computer_name <- Sys.info()["nodename"]
    
    # Multiple detection methods for robustness
    if (current_user == "jdp2019") {
      computer <- "laptop"
      cat("🔍 Detected laptop via username:", current_user, "\n")
    } else if (current_user == "JoshsMacbook2015" || grepl("JoshsMacbook", computer_name) || grepl("JDP", computer_name)) {
      computer <- "desktop"
      cat("🔍 Detected desktop via username/computer name:", current_user, "/", computer_name, "\n")
    } else {
      # Fallback: check for specific path signatures
      if (dir.exists("/Users/jdp2019")) {
        computer <- "laptop"
        cat("🔍 Detected laptop via path signature\n")
      } else if (dir.exists("/Users/JoshsMacbook2015")) {
        computer <- "desktop"
        cat("🔍 Detected desktop via path signature\n")
      } else {
        stop("Could not auto-detect computer. Available: 'laptop' (jdp2019) or 'desktop' (JoshsMacbook2015). ",
             "Current user: ", current_user, ", Computer: ", computer_name,
             "\nPlease specify computer = 'laptop' or computer = 'desktop'")
      }
    }
  }
  
  # Validate computer selection
  if (!computer %in% names(raw_config$computers)) {
    stop("Invalid computer selection. Available options: ", 
         paste(names(raw_config$computers), collapse = ", "))
  }
  
  cat("🖥️ Using configuration for:", computer, "\n")
  
  # Get computer-specific variables
  comp_vars <- raw_config$computers[[computer]]
  
  # Create substitution variables including derived ones
  substitution_vars <- comp_vars
  substitution_vars$base_data_path <- glue::glue(
    raw_config$paths$base_data_path, 
    .envir = comp_vars
  )
  
  # Recursively substitute variables in all path strings
  resolve_paths <- function(obj, vars) {
    if (is.list(obj)) {
      return(lapply(obj, resolve_paths, vars))
    } else if (is.character(obj) && length(obj) == 1) {
      # Only substitute if string contains template variables
      if (grepl("\\{.*\\}", obj)) {
        return(as.character(glue::glue(obj, .envir = vars)))
      } else {
        return(obj)
      }
    } else {
      return(obj)
    }
  }
  
  # Resolve all paths
  resolved_config <- raw_config
  resolved_config$paths <- resolve_paths(raw_config$paths, substitution_vars)
  
  # Remove the computers section from final config
  resolved_config$computers <- NULL
  
  # Add metadata about which computer was used
  resolved_config$computer_used <- computer
  
  return(resolved_config)
}