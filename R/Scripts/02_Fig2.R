#* Figure 2
  #+ 2A) Pathway Enrichment
    #- Filter to relevant columns
      pathway_enrich_raw <- UFT_C18_HILIC %>%
        select(-Patient_no) %>%
        mutate(PGD = as.factor(PGD))
    #- Run ttest of each feature and format for metaboanalyst
      ttest_results_pathway <- pathway_enrich_raw %>%
        pivot_longer(cols = -PGD, names_to = "Feature", values_to = "Value") %>%
        group_by(Feature) %>%
        summarize(
          p_value = t.test(Value[PGD == "Yes"], Value[PGD == "No"])$p.value,
          mean_PGD_yes = mean(Value[PGD == "Yes"], na.rm = TRUE),
          mean_PGD_no = mean(Value[PGD == "No"], na.rm = TRUE)
        ) %>%
        arrange(p_value) %>%
        separate(Feature, into = c("mode", "m.z", "r.t"), sep = "_", convert = TRUE) %>%
        mutate(
          mode = ifelse(mode == "HILIC", "positive", "negative"),
          p.value = p_value # Rename p_value to p.value
        ) %>%
        select(m.z, mode, p.value, r.t) 
      write.csv(ttest_results_pathway, "pathway_enrichment_data.csv", row.names = FALSE)
    #- Import results from mummichog
      pathway_enrich_results <- read_excel("Outputs/mummichog.xlsx", sheet = "summary") %>%
        select(pathway_name, p_gamma, enrichment_factor) %>%
        filter(p_gamma < 0.05) %>%
        arrange(desc(enrichment_factor), p_gamma) # Sort by bubble size (enrichment factor)
    #- Create the balloon plot
      ggplot(pathway_enrich_results, aes(
        x = 1, y = reorder(pathway_name, enrichment_factor),
        size = enrichment_factor, color = p_gamma
      )) +
        geom_point(alpha = 0.8) + # Bubbles with some transparency
        scale_size_continuous(
          range = c(3, 15), name = "Enrichment Factor"
        ) +
        guides(size = guide_legend(reverse = TRUE)) + # Reverse the legend
        scale_color_gradient(
          low = "#800017", high = "#EFD8DC", name = "P-Value"
        ) +
        theme_minimal(base_family = "Arial") +
        theme(
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_text(size = 16, face = "bold", color = "black"), # Ensures pure black Y-axis text
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          legend.title = element_text(size = 16, face = "bold"),
          legend.text = element_text(size = 16),
          legend.key.height = unit(1.5, "cm"), # Adjust space between keys to center title vertically
          legend.text.align = 0.5 # Center-align legend text horizontally
        )
  #+ 2B) KEGG Map
    #! Done on Metaboanalyst