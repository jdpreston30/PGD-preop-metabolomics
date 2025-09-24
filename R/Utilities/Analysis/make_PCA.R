#' Create PCA or PLS-DA plot with ellipses
#'
#' @param data Data frame with Patient_ID, Variant, and feature columns
#' @param method Method to use: "PCA" or "PLSDA" (default: "PCA")
#' @param plot_title Optional title for the plot (default: "")
#' @param ellipse_colors Named vector of colors for ellipses (light colors)
#' @param point_colors Named vector of colors for points (dark colors)
#' @param point_size Size of the points (default: 3 for standalone, 0.5 for multi-panel)
#' @param comp_x Which component to plot on x-axis (default: 1)
#' @param comp_y Which component to plot on y-axis (default: 2)
#' @param ncomp Number of components for PLS-DA (default: 2)
#' @param show_patient_labels Logical, whether to show Patient IDs as text labels (default: FALSE)
#' @param label_size Size of patient ID labels when show_patient_labels = TRUE (default: 3)
#' @return List containing the plot, model object, scores, scores_df, and explained variance
#' @export
make_PCA <- function(data, method = "PCA", plot_title = "",
                     ellipse_colors = c("Y" = "#D8919A", "N" = "#87A6C7", "Control" = "#B0B0B0"),
                     point_colors = c("Y" = "#800017", "N" = "#113d6a", "Control" = "#4c4c4c"),
                     point_size = 3, comp_x = 1, comp_y = 2, ncomp = 2, 
                     show_patient_labels = FALSE, label_size = 3) {
  # _Data preparation
  df <- as.data.frame(data)
  cls_col <- if ("Variant" %in% names(df)) "Variant" else names(df)[2]
  X <- df[, -c(1, 2), drop = FALSE]
  # _Coerce to numeric safely
  X[] <- lapply(X, function(v) suppressWarnings(as.numeric(v)))
  # _Handle NAs with median imputation
  if (anyNA(X)) {
    X[] <- lapply(X, function(v) {
      v[is.na(v)] <- stats::median(v, na.rm = TRUE)
      v
    })
  }
  Y <- factor(df[[cls_col]])

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
    comp_label <- "Comp"
  }

  # _Prepare plot data
  scores_df <- data.frame(
    Comp1 = scores[, 1],
    Comp2 = scores[, 2],
    Class = Y,
    Patient = df[, 1]  # Add Patient IDs from first column
  )

  # Identify NA values and create separate datasets
  na_mask <- is.na(scores_df$Class)
  scores_df_complete <- scores_df[!na_mask, , drop = FALSE]
  scores_df_na <- scores_df[na_mask, , drop = FALSE]

  # _Create PCA plot
  pca_plot <- ggplot2::ggplot() +
    # Plot complete cases with colors and ellipses
    {
      if (nrow(scores_df_complete) > 0) {
        list(
          ggplot2::geom_point(
            data = scores_df_complete,
            ggplot2::aes(x = Comp1, y = Comp2, color = Class),
            size = point_size, shape = 16
          ),
          ggplot2::stat_ellipse(
            data = scores_df_complete,
            ggplot2::aes(x = Comp1, y = Comp2, fill = Class),
            geom = "polygon", alpha = 0.3, color = NA
          )
        )
      }
    } +
    # Plot NA values as open circles without color
    {
      if (nrow(scores_df_na) > 0) {
        ggplot2::geom_point(
          data = scores_df_na,
          ggplot2::aes(x = Comp1, y = Comp2),
          size = point_size, shape = 1, color = "black", fill = NA
        )
      }
    } +
    # Add patient labels if requested
    {
      if (show_patient_labels) {
        list(
          if (nrow(scores_df_complete) > 0) {
            ggplot2::geom_text(
              data = scores_df_complete,
              ggplot2::aes(x = Comp1, y = Comp2, label = Patient),
              size = label_size, hjust = 0.5, vjust = -0.5, color = "black"
            )
          },
          if (nrow(scores_df_na) > 0) {
            ggplot2::geom_text(
              data = scores_df_na,
              ggplot2::aes(x = Comp1, y = Comp2, label = Patient),
              size = label_size, hjust = 0.5, vjust = -0.5, color = "black"
            )
          }
        )
      }
    } +
    ggplot2::scale_color_manual(values = point_colors, drop = TRUE, na.translate = FALSE) +
    ggplot2::scale_fill_manual(values = ellipse_colors, drop = TRUE, na.translate = FALSE) +
    ggplot2::theme_minimal(base_family = "Arial") +
    ggplot2::labs(
      x = paste0(comp_label, comp_x, " (", explained[1], "%)"),
      y = paste0(comp_label, comp_y, " (", explained[2], "%)")
    ) +
    ggplot2::theme(
      axis.title = ggplot2::element_text(size = 25, face = "bold"),
      axis.text = ggplot2::element_text(size = 22, face = "bold", color = "black"),
      legend.position = "none",
      panel.grid.major = ggplot2::element_line(color = "gray80", linewidth = 0.8, linetype = "solid"),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(color = "black", fill = NA, linewidth = 3.2),
      panel.background = ggplot2::element_blank()
    )

  # _Check for batch effects (sequential patient clustering)
  if (method == "PCA") {
    patient_nums <- as.numeric(gsub("[^0-9]", "", scores_df$Patient))
    if (any(!is.na(patient_nums))) {
      pc1_patient_cor <- cor(patient_nums, scores_df$Comp1, use = "complete.obs")
      if (abs(pc1_patient_cor) > 0.3) {
        warning(paste("Potential batch effect detected! Correlation between Patient number and PC1:",
                     round(pc1_patient_cor, 3), 
                     "- Sequential patients are clustering together."))
      }
    }
  }

  # _Return useful objects for further analysis
  return(list(
    plot = pca_plot,
    model = model,
    scores = scores,
    scores_df = scores_df,
    explained = explained,
    method = method
  ))
}
