#* 5: Data Not Shown ----
#+ 5.1: Rates and n's of PGD grade ----
#- 5.1.1: Compute the counts and percentages of each PGD grade ----
postop_PGD_grade_ISHLT_counts <- clinical_metadata %>%
  group_by(postop_PGD_grade_ISHLT) %>%
  summarise(n = n()) %>%
  mutate(percentage = n / sum(n) * 100)
#- 5.1.2: Create and display results sentence ----
pgd_grades_sentence <- paste("Of the", sum(postop_PGD_grade_ISHLT_counts$n), "patients,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "N"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "N"]), "%)"), "had no PGD,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Mild"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Mild"]), "%)"), "had mild PGD,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Moderate"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Moderate"]), "%)"), "had moderate PGD, and",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Severe"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Severe"]), "%)"), "had severe PGD.")
#- 5.1.3: Print the sentence when needed ----
cat(pgd_grades_sentence, "\n")
