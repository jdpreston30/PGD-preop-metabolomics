#' Create heatmap with optional feature selection (ANOVA / variance / MAD)
#' and configurable annotation. Returns plot object for patchwork.
#'
#' @param data                 Data frame with Patient_ID, annotation variable, and feature columns
#' @param group_var            Character string specifying the column name to use for grouping/annotation
#' @param patient_var          Character string specifying the Patient ID column name (default: "Patient_ID")
#' @param group_colors         Named color vector for the grouping variable (names = levels)
#' @param top_features         NULL (default: show all features). If numeric >0, keep top N by `feature_selector`.
#' @param feature_selector     One of c("none","anova","ttest","variance","mad"). Default "none".
#' @param group_levels         Factor order for the grouping variable (optional)
#' @return List with plot object, M, Mz, hc_cols, ann_col, ann_colors, etc.
#' @export
make_heatmap <- function(
    data,
    group_var,
    patient_var = "Patient_ID",
    group_colors = c("Severe PGD" = "#D8919A", "No PGD" = "#87A6C7", "Mild/Moderate PGD" = "#9CAF88"),
    top_features = NULL,
    feature_selector = c("none", "anova", "ttest", "variance", "mad"),
    group_levels = NULL) {
  feature_selector <- match.arg(feature_selector)

  # ---- Checks ----
  if (!group_var %in% names(data)) {
    stop(paste("Group variable", group_var, "not found in data"))
  }
  if (!patient_var %in% names(data)) {
    stop(paste("Patient variable", patient_var, "not found in data"))
  }

  # Keep ID and grouping variable up front, then everything else
  dat <- dplyr::select(
    data,
    dplyr::all_of(c(patient_var, group_var)),
    dplyr::everything()
  )

  # Coerce grouping variable to factor in desired order (if specified)
  if (!is.null(group_levels)) {
    dat[[group_var]] <- factor(dat[[group_var]], levels = group_levels)
  } else {
    dat[[group_var]] <- factor(dat[[group_var]])
  }

  # Identify factor columns (excluding Patient and grouping variable)
  factor_cols <- sapply(dat, is.factor)
  cols_to_exclude <- c(patient_var, group_var)
  other_factor_cols <- names(factor_cols)[factor_cols & !names(factor_cols) %in% cols_to_exclude]
  
  # Build matrix: samples x features (drop ID, grouping variable, and other factor columns)
  drop_cols <- c(cols_to_exclude, other_factor_cols)
  numeric_cols <- !names(dat) %in% drop_cols
  X <- as.matrix(dplyr::select(dat, dplyr::all_of(names(dat)[numeric_cols])))
  
  # Check that we have numeric data
  if (ncol(X) == 0) stop("No numeric columns found for heatmap")
  stopifnot(all(vapply(as.data.frame(X), is.numeric, TRUE)))

  # Sample IDs (use make.names for uniqueness + valid rownames)
  sample_ids <- make.names(dat[[patient_var]], unique = TRUE)
  rownames(X) <- sample_ids

  # Group factor for ANOVA ranking
  group <- dat[[group_var]]

  # ---- Optional feature ranking/selection ----
  if (!is.null(top_features) && is.numeric(top_features) && top_features > 0 &&
    feature_selector != "none") {
    top_n <- min(top_features, ncol(X))

    rank_idx <- switch(feature_selector,
      "anova" = {
        pvals <- apply(X, 2, function(x) {
          fit <- aov(x ~ group)
          summary(fit)[[1]][["Pr(>F)"]][1]
        })
        order(pvals, na.last = TRUE) # ascending p
      },
      "ttest" = {
        # Check if exactly 2 groups for t-test
        n_groups <- length(levels(group))
        if (n_groups != 2) {
          warning(paste("t-test requires exactly 2 groups, but found", n_groups, "groups. Switching to ANOVA."))
          pvals <- apply(X, 2, function(x) {
            fit <- aov(x ~ group)
            summary(fit)[[1]][["Pr(>F)"]][1]
          })
        } else {
          pvals <- apply(X, 2, function(x) {
            t_result <- t.test(x ~ group)
            t_result$p.value
          })
        }
        order(pvals, na.last = TRUE) # ascending p
      },
      "variance" = {
        v <- apply(X, 2, stats::var, na.rm = TRUE)
        order(v, decreasing = TRUE, na.last = NA)
      },
      "mad" = {
        m <- apply(X, 2, stats::mad, na.rm = TRUE)
        order(m, decreasing = TRUE, na.last = NA)
      }
    )

    X <- X[, head(rank_idx, top_n), drop = FALSE]
  }

  # Drop zero-variance columns (after selection)
  nzv <- apply(X, 2, sd, na.rm = TRUE) > 0
  if (!all(nzv)) X <- X[, nzv, drop = FALSE]
  if (!ncol(X)) stop("No features remain after selection/variance filtering.")

  # Heatmap matrix: features x samples
  M <- t(X)

  # ---- Sample clustering for dendrogram only ----
  Mz <- t(scale(t(M), center = TRUE, scale = TRUE))
  Mz[is.na(Mz)] <- 0
  d_cols <- dist(t(Mz), method = "euclidean")
  hc_cols <- hclust(d_cols, method = "complete")

  # ---- Column annotation (aligned to columns of M) ----
  # Simple annotation with just the grouping variable
  ann_col <- data.frame(row.names = sample_ids)
  ann_col[[group_var]] <- dat[[group_var]]

  # Reorder rows of ann_col to match M's columns
  ann_col <- ann_col[colnames(M), , drop = FALSE]

  # ---- Annotation color lists ----
  ann_colors <- list()

  # Add grouping variable colors
  ann_colors[[group_var]] <- group_colors

  # ---- Heatmap (for screen) ----
  heatmap_plot <- pheatmap::pheatmap(
    M,
    scale = "row",
    color = colorRampPalette(rev(RColorBrewer::brewer.pal(11, "RdBu")))(255),
    clustering_distance_rows = "euclidean",
    clustering_distance_cols = "euclidean",
    clustering_method = "complete",
    annotation_col = ann_col,
    annotation_colors = ann_colors,
    show_rownames = FALSE,
    show_colnames = FALSE,
    fontsize = 10,
    na_col = "#DDDDDD",
    legend_labels = "Z-Score"
  )

  # Create heatmap plot object for patchwork
  heatmap_plot <- pheatmap::pheatmap(
    M,
    scale = "row",
    color = colorRampPalette(rev(RColorBrewer::brewer.pal(11, "RdBu")))(255),
    clustering_distance_rows = "euclidean",
    clustering_distance_cols = "euclidean",
    clustering_method = "complete",
    annotation_col = ann_col,
    annotation_colors = ann_colors,
    show_rownames = FALSE,
    show_colnames = FALSE,
    fontsize = 8,
    na_col = "#DDDDDD",
    silent = TRUE, # Prevents auto-display
    legend_labels = "Z-Score"
  )

  list(
    M = M,
    Mz = Mz,
    hc_cols = hc_cols,
    sample_ids = sample_ids,
    group = group,
    feature_selector = feature_selector,
    top_features = top_features,
    ann_col = ann_col,
    ann_colors = ann_colors,
    heatmap_plot = heatmap_plot # Plot object for patchwork
  )
}
