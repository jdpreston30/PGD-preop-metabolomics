#' Run PCA or PLS-DA analysis on metabolomics data
#'
#' @param data Data frame with Patient column and feature columns
#' @param group_var Character string specifying the column name to use for grouping
#' @param patient_var Character string specifying the Patient ID column name (default: "Patient")
#' @param method Method to use: "PCA" or "PLSDA" (default: "PCA")
#' @param comp_x Which component to extract for x-axis (default: 1)
#' @param comp_y Which component to extract for y-axis (default: 2)
#' @param ncomp Number of components for PLS-DA (default: 2)
#' @return List containing model, scores, scores_df, explained variance, and metadata
#' @export
run_PCA <- function(data, group_var, patient_var = "Patient", method = "PCA", 
                    comp_x = 1, comp_y = 2, ncomp = 2) {
  
  # _Data preparation
  df <- as.data.frame(data)
  
  # Check if required columns exist
  if (!group_var %in% names(df)) {
    stop(paste("Group variable", group_var, "not found in data"))
  }
  if (!patient_var %in% names(df)) {
    stop(paste("Patient variable", patient_var, "not found in data"))
  }
  
  # Identify factor columns (excluding Patient and grouping variable)
  factor_cols <- sapply(df, is.factor)
  cols_to_exclude <- c(patient_var, group_var)
  other_factor_cols <- names(factor_cols)[factor_cols & !names(factor_cols) %in% cols_to_exclude]
  
  # Select numeric columns for analysis (exclude Patient, group_var, and other factor columns)
  exclude_cols <- c(cols_to_exclude, other_factor_cols)
  numeric_cols <- !names(df) %in% exclude_cols
  X <- df[, numeric_cols, drop = FALSE]
  
  # Informative message about excluded columns
  if (length(exclude_cols) > 2) {  # More than just patient and grouping vars
    message("Excluded factor columns (besides Patient and grouping): ", 
            paste(other_factor_cols, collapse = ", "))
  }
  message("Using ", ncol(X), " numeric features for analysis")
  
  # _Coerce to numeric safely
  X[] <- lapply(X, function(v) suppressWarnings(as.numeric(v)))
  # _Handle NAs with median imputation
  if (anyNA(X)) {
    X[] <- lapply(X, function(v) {
      v[is.na(v)] <- stats::median(v, na.rm = TRUE)
      v
    })
  }
  Y <- factor(df[[group_var]])

  # _Perform analysis based on method
  method <- match.arg(method, c("PCA", "PLSDA"))
  
  if (method == "PCA") {
    model <- stats::prcomp(X, center = TRUE, scale. = TRUE)
    max_comp <- min(ncol(X), nrow(X) - 1)
    if (comp_x > max_comp || comp_y > max_comp) {
      stop(paste("Requested components exceed available components. Max components:", max_comp))
    }
    scores <- model$x[, c(comp_x, comp_y), drop = FALSE]
    explained <- round((model$sdev^2 / sum(model$sdev^2))[c(comp_x, comp_y)] * 100)
    # Calculate explained variance for first 10 components (or max available)
    n_comp_all <- min(10, max_comp)
    explained_all <- round((model$sdev^2 / sum(model$sdev^2))[1:n_comp_all] * 100, 2)
    comp_label <- "PC"
  } else {
    # PLS-DA using mixOmics
    if (!requireNamespace("mixOmics", quietly = TRUE)) {
      stop("Package 'mixOmics' is required for PLS-DA. Please install it.")
    }
    model <- mixOmics::plsda(X, Y, ncomp = ncomp)
    max_comp <- min(ncomp, ncol(X), nrow(X) - 1)
    if (comp_x > max_comp || comp_y > max_comp) {
      stop(paste("Requested components exceed available components. Max components:", max_comp))
    }
    scores <- model$variates$X[, c(comp_x, comp_y), drop = FALSE]
    explained <- round(model$prop_expl_var$X[c(comp_x, comp_y)] * 100)
    # Calculate explained variance for first 10 components (or max available)
    n_comp_all <- min(10, max_comp)
    explained_all <- round(model$prop_expl_var$X[1:n_comp_all] * 100, 2)
    comp_label <- "LV"
  }

  # _Prepare analysis results
  scores_df <- data.frame(
    Comp1 = scores[, 1],
    Comp2 = scores[, 2],
    Class = Y,
    Patient = df[[patient_var]]  # Add Patient IDs from specified column
  )

  # Return analysis results
  list(
    method = method,
    model = model,
    scores = scores,
    scores_df = scores_df,
    explained_variance = explained,
    explained_variance_all = explained_all,
    comp_x = comp_x,
    comp_y = comp_y,
    comp_label = comp_label,
    group_var = group_var,
    patient_var = patient_var,
    original_data = df
  )
}
