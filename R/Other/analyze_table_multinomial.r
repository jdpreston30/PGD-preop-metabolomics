analyze_table_multinomial <- function(data, multinomial_vars) {
      # Filter only multinomial variables that exist in the dataset
      multinomial_vars <- multinomial_vars[multinomial_vars %in% colnames(data)]

      #  Process Multinomial Variables 
      multinomial_results <- map_dfr(multinomial_vars, function(var) {
        if (!var %in% colnames(data)) {
          return(NULL)
        }

        # Perform Fisher's exact test
        fisher_result <- fisher.test(table(data[[var]], data$postop_PGD))

        # Create a count table
        table_data <- data %>%
          group_by(postop_PGD, !!sym(var)) %>%
          summarise(n = n(), .groups = "drop") %>%
          pivot_wider(names_from = !!sym(var), values_from = n, values_fill = list(n = 0)) %>%
          pivot_longer(cols = -postop_PGD, names_to = "Category", values_to = "Count") %>%
          mutate(Percent = Count / sum(Count, na.rm = TRUE) * 100) %>%
          mutate(Formatted = sprintf("%d (%.1f%%)", Count, Percent))

        if (nrow(table_data) == 0) {
          return(NULL)
        }

        # Format output
        table_data %>%
          mutate(
            Variable = var,
            p_value = round(fisher_result$p.value, 3),
            sig = case_when(
              p_value < 0.001 ~ "***",
              p_value < 0.01 ~ "**",
              p_value < 0.05 ~ "*",
              TRUE ~ ""
            ),
            Variable_Type = "Multinomial"
          ) %>%
          select(Variable, Category, `-PGD` = Formatted, `+PGD` = Formatted, p_value, sig, Variable_Type)
      })

      return(multinomial_results)
    }