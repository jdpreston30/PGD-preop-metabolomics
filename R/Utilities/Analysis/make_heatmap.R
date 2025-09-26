#' Create heatmap with optional feature selection (ANOVA / variance / MAD)
#' and configurable annotation. Returns plot object for patchwork.
#'
#' @param data                 Data frame with Patient_ID, annotation variable, and feature columns
#' @param group_var            Character string specifying the column name to use for grouping/annotation
#' @param patient_var          Character string specifying the Patient ID column name (default: "Patient_ID")
#' @param group_colors         Named color vector for the grouping variable (names = levels)
#' @param top_features         NULL (default: show all features). If numeric >0, keep top N by `feature_selector`.
#' @param feature_selector     One of c("none","anova","variance","mad"). Default "none".
#' @param group_levels         Factor order for the grouping variable (optional)
#' @return List with plot object, M, Mz, hc_cols, ann_col, ann_colors, etc.
#' @export
make_heatmap <- function(
    data,
    group_var,
    patient_var = "Patient_ID",
    group_colors = c("Severe" = "#D8919A", "No PGD" = "#87A6C7", "Non-Severe" = "#9CAF88"),
    top_features = NULL,
    feature_selector = c("none", "anova", "variance", "mad"),
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

  # ---- Sample clustering & clades ----
  Mz <- t(scale(t(M), center = TRUE, scale = TRUE))
  Mz[is.na(Mz)] <- 0
  d_cols <- dist(t(Mz), method = "euclidean")
  hc_cols <- hclust(d_cols, method = "complete")

  # Map back to original Patient_ID
  id_map <- setNames(dat[[patient_var]], sample_ids)
  clades_raw <- stats::cutree(hc_cols, k = n_clades)

  # Assign clusters based on dendrogram order: leftmost = Cluster 1, rightmost = Cluster 2
  # Get the order of samples from the dendrogram
  ordered_samples <- names(clades_raw)[hc_cols$order]

  # Find which raw cluster appears first (leftmost) in the dendrogram order
  first_cluster_raw <- clades_raw[ordered_samples[1]]

  # Assign final cluster numbers: leftmost cluster becomes Cluster 1, rightmost becomes Cluster 2
  clades <- ifelse(clades_raw == first_cluster_raw, 1, 2)

  ids_ordered_clean <- names(clades)[hc_cols$order]
  ids_ordered_orig <- unname(id_map[ids_ordered_clean])

  cluster_df <- tibble::tibble(
    Patient_ID = ids_ordered_orig,
    Cluster    = unname(clades[ids_ordered_clean])
  )

  cluster_lists <- lapply(seq_len(n_clades), function(i) {
    cluster_df %>%
      dplyr::filter(Cluster == i) %>%
      dplyr::pull(Patient_ID)
  })
  names(cluster_lists) <- paste0("cluster", seq_len(n_clades), "_ids")

  # ---- Column annotation (aligned to columns of M) ----
  # Build annotation with grouping variable and clusters
  # Start with grouping variable annotation (will be on bottom)
  ann_col <- data.frame(row.names = sample_ids)
  ann_col[[group_var]] <- dat[[group_var]]

  # Add cluster annotation (will be on top)
  # Create a mapping from sample_ids to final cluster assignments
  cluster_mapping <- setNames(cluster_df$Cluster, cluster_df$Patient_ID)
  original_ids <- unname(id_map[sample_ids]) # Convert sample_ids back to original Patient_IDs
  cluster_labels <- paste0("Cluster ", cluster_mapping[original_ids])
  names(cluster_labels) <- sample_ids

  # Use standard factor levels - legend order controlled by color order
  ann_col$Cluster <- factor(cluster_labels[sample_ids], levels = c("Cluster 1", "Cluster 2"))

  # Reorder rows of ann_col to match M's columns
  ann_col <- ann_col[colnames(M), , drop = FALSE]

  # ---- Annotation color lists ----
  ann_colors <- list()

  # Add grouping variable colors (will display at bottom)
  ann_colors[[group_var]] <- group_colors

  # Add cluster colors (will display at top)
  if (!is.null(cluster_colors)) {
    ann_colors$Cluster <- cluster_colors[c("Cluster 1", "Cluster 2")]
  } else {
    # Default cluster colors if not provided
    default_cluster_colors <- c("Cluster 1" = "#94001E", "Cluster 2" = "#03507D")
    ann_colors$Cluster <- default_cluster_colors
  }

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
    cluster_df = cluster_df, # Updated from clade_df
    clusters = clades, # Updated from clades
    cluster_lists = cluster_lists, # Updated from clade_lists
    heatmap_plot = heatmap_plot # Plot object for patchwork
  )
}
