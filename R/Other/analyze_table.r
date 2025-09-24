analyze_table <- function(data, cont_vars, dichotomous_vars, dichotomous_nominal_vars, ordinal_vars) {
      data <- data %>% mutate(postop_PGD = recode(postop_PGD, "No" = "-PGD", "Yes" = "+PGD"))

      cont_vars <- cont_vars[cont_vars %in% colnames(data)]
      dichotomous_vars <- dichotomous_vars[dichotomous_vars %in% colnames(data)]
      dichotomous_nominal_vars <- dichotomous_nominal_vars[dichotomous_nominal_vars %in% colnames(data)]
      ordinal_vars <- ordinal_vars[ordinal_vars %in% colnames(data)]

      # ---- Continuous Variables ----
      continuous_results <- map_dfr(cont_vars, function(var) {
        group_stats <- data %>%
          group_by(postop_PGD) %>%
          summarise(Mean = mean(!!sym(var), na.rm = TRUE), SD = sd(!!sym(var), na.rm = TRUE), .groups = "drop")

        total_stats <- data %>%
          summarise(Mean = mean(!!sym(var), na.rm = TRUE), SD = sd(!!sym(var), na.rm = TRUE))

        if (nrow(group_stats) < 2) {
          return(NULL)
        }

        t_test_result <- t.test(data[[var]] ~ data$postop_PGD, na.action = na.omit)

        tibble(
          Variable = var,
          `-PGD` = sprintf("%.1f ± %.1f", group_stats$Mean[group_stats$postop_PGD == "-PGD"], group_stats$SD[group_stats$postop_PGD == "-PGD"]),
          `+PGD` = sprintf("%.1f ± %.1f", group_stats$Mean[group_stats$postop_PGD == "+PGD"], group_stats$SD[group_stats$postop_PGD == "+PGD"]),
          Total = sprintf("%.1f ± %.1f", total_stats$Mean, total_stats$SD),
          p_value = round(t_test_result$p.value, 3),
          sig = case_when(p_value < 0.001 ~ "***", p_value < 0.01 ~ "**", p_value < 0.05 ~ "*", TRUE ~ ""),
          Minority_Group = NA,
          Variable_Type = "Continuous"
        )
      })

      # ---- Ordinal Variables ----
      ordinal_results <- map_dfr(ordinal_vars, function(var) {
        group_stats <- data %>%
          group_by(postop_PGD) %>%
          summarise(
            Median = median(!!sym(var), na.rm = TRUE),
            IQR_low = quantile(!!sym(var), 0.25, na.rm = TRUE),
            IQR_high = quantile(!!sym(var), 0.75, na.rm = TRUE),
            .groups = "drop"
          )

        total_stats <- data %>%
          summarise(
            Median = median(!!sym(var), na.rm = TRUE),
            IQR_low = quantile(!!sym(var), 0.25, na.rm = TRUE),
            IQR_high = quantile(!!sym(var), 0.75, na.rm = TRUE)
          )

        if (nrow(group_stats) < 2) {
          return(NULL)
        }

        wilcox_result <- wilcox.test(data[[var]] ~ data$postop_PGD, na.action = na.omit, exact = FALSE)

        tibble(
          Variable = var,
          `-PGD` = sprintf(
            "%.1f [%.1f–%.1f]", group_stats$Median[group_stats$postop_PGD == "-PGD"],
            group_stats$IQR_low[group_stats$postop_PGD == "-PGD"],
            group_stats$IQR_high[group_stats$postop_PGD == "-PGD"]
          ),
          `+PGD` = sprintf(
            "%.1f [%.1f–%.1f]", group_stats$Median[group_stats$postop_PGD == "+PGD"],
            group_stats$IQR_low[group_stats$postop_PGD == "+PGD"],
            group_stats$IQR_high[group_stats$postop_PGD == "+PGD"]
          ),
          Total = sprintf("%.1f [%.1f–%.1f]", total_stats$Median, total_stats$IQR_low, total_stats$IQR_high),
          p_value = round(wilcox_result$p.value, 3),
          sig = case_when(p_value < 0.001 ~ "***", p_value < 0.01 ~ "**", p_value < 0.05 ~ "*", TRUE ~ ""),
          Minority_Group = NA,
          Variable_Type = "Ordinal"
        )
      })

      # ---- Dichotomous Variables ----
      dichotomous_results <- map_dfr(dichotomous_vars, function(var) {
        table_counts <- data %>%
          group_by(postop_PGD, !!sym(var)) %>%
          summarise(n = n(), .groups = "drop") %>%
          pivot_wider(names_from = !!sym(var), values_from = n, values_fill = list(n = 0))

        if (!all(c("Yes", "No") %in% colnames(table_counts))) {
          return(NULL)
        }

        fisher_result <- fisher.test(as.matrix(table_counts[, c("Yes", "No")]))

        tibble(
          Variable = paste0(var, "_No"),
          `-PGD` = sprintf("%d (%.1f%%)", table_counts$No[1], table_counts$No[1] / sum(table_counts[1, c("Yes", "No")]) * 100),
          `+PGD` = sprintf("%d (%.1f%%)", table_counts$No[2], table_counts$No[2] / sum(table_counts[2, c("Yes", "No")]) * 100),
          Total = sprintf("%d (%.1f%%)", sum(table_counts$No), sum(table_counts$No) / sum(table_counts[2:3]) * 100),
          p_value = round(fisher_result$p.value, 3),
          sig = case_when(p_value < 0.001 ~ "***", p_value < 0.01 ~ "**", p_value < 0.05 ~ "*", TRUE ~ ""),
          Minority_Group = NA,
          Variable_Type = "Dichotomous"
        )
      })

      summary_tibble <- bind_rows(continuous_results, ordinal_results, dichotomous_results) %>%
        arrange(Variable)

      return(summary_tibble)
    }