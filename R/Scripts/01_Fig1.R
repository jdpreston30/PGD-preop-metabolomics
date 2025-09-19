#* 1: Figure 1
  #+ 1.1: Create Heatmap
    # ! Created in Metaboanalyst
  #+ 1.2: Graph PLS-DA
    #- 1.2.1: Prepare data
      X <- UFT_C18_HILIC[, -c(1, 2)] # Drop 'Patient_no' and 'PGD' columns
      Y <- UFT_C18_HILIC$PGD # The response variable
    #- 1.2.2: Fit PLS-DA model
      plsda_model <- plsda(X, Y, ncomp = 2)
    #- 1.2.3: Extract scores for the first two components
      scores <- plsda_model$variates$X
    #- 1.2.4: Correctly calculate explained variance using the model's eigenvalues
      explained_variance <- round(plsda_model$prop_expl_var$X[1:2] * 100)
    #- 1.2.5: Create data frame for ggplot
      scores_df <- data.frame(
        Comp1 = scores[, 1],
        Comp2 = scores[, 2],
        PGD = Y
      )
    #- 1.2.6: Assign colors and ellipses colors
      ellipse_colors <- c("Yes" = "#D8919A", "No" = "#87A6C7", "Control" = "#B0B0B0")
      point_colors <- c("Yes" = "#800017", "No" = "#113d6a", "Control" = "#4c4c4c")
    #- 1.2.7: Graph
      fig2b <- ggplot(scores_df, aes(x = Comp1, y = Comp2, color = PGD)) +
        geom_point(size = 3, shape = 21, stroke = 0.8, fill = point_colors[scores_df$PGD]) +
        stat_ellipse(geom = "polygon", aes(fill = PGD), alpha = 0.3, color = NA) +
        scale_color_manual(values = point_colors) +
        scale_fill_manual(values = ellipse_colors) +
        theme_minimal(base_family = "Arial") +
        labs(
          x = paste0("Component 1 (", explained_variance[1], "%)"),
          y = paste0("Component 2 (", explained_variance[2], "%)")
        ) +
        theme(
          axis.title = element_text(size = 25, face = "bold"), # Scaled up
          axis.text = element_text(size = 22, face = "bold", color = "black"), # Black axis text
          legend.position = "none",
          panel.grid.major = element_line(color = "gray80", size = 0.8, linetype = "solid"), # Scaled grid
          panel.grid.minor = element_blank(),
          panel.border = element_rect(color = "black", fill = NA, linewidth = 3.2), # Scaled frame
          panel.background = element_blank()
        )
        fig2b
    #- 1.2.8: Save as SVG with 1:1 ratio
      ggsave(
        filename = "fig2b.svg",
        plot = fig2b,
        device = "svg",
        width = 8, # Set width and height to be the same for 1:1 aspect ratio
        height = 8,
        units = "in",
        dpi = 600 # Ensure high resolution if needed
      )
  #+ 1.3: Volcano Plot
    #- 1.3.1: Prepare data and perform t-tests
      ttest_results_sig <- UFT_C18_HILIC %>%
        select(-Patient_no) %>%
        pivot_longer(-PGD, names_to = "Feature", values_to = "Log2_Value") %>%
        group_by(Feature) %>%
        summarise(
          # Reverse log2 transformation to calculate original means
          mean_yes = mean(2^Log2_Value[PGD == "Yes"], na.rm = TRUE),
          mean_no = mean(2^Log2_Value[PGD == "No"], na.rm = TRUE),
          mean_ratio = mean_yes / mean_no,

          # p-value using log2-transformed data
          p_value = t.test(Log2_Value[PGD == "Yes"], Log2_Value[PGD == "No"], var.equal = TRUE)$p.value,
          neg_log_p = -log10(p_value),

          # Calculate log2FC using original means
          log2FC = log2(mean_ratio),
          .groups = "drop"
        ) %>%
        mutate(
          # Assign color based on log2FC and p-value threshold
          color = case_when(
            p_value < 0.05 & log2FC >= log2(1.5) ~ "red", # Upregulated (≥ 1.5-fold & significant)
            p_value < 0.05 & log2FC <= -log2(1.5) ~ "blue", # Downregulated (≤ 1/1.5-fold & significant)
            TRUE ~ "black" # Non-significant
          )
        ) %>%
        arrange(desc(color))
    #- 1.3.2: Save results and count significant features
      write.csv(ttest_results_sig, "volcano.csv")
      number_down <- nrow(ttest_results_sig %>%
        filter(color == "blue"))
      number_up <- nrow(ttest_results_sig %>%
        filter(color == "red"))
      number_sig <- nrow(ttest_results_sig %>%
        filter(p_value <= 0.05))
    #- 1.3.3: Graph results
      # ! Graphed from here in Prism