#* 6: Data Not Shown
#+ 6.1: Percent of samples arterial versus venous
#- 6.1.1: Generate sample composition summary ----
sample_summary <- sample_type %>%
  summarise(
    total_samples = n(),
    arterial_count = sum(sample_source == "A", na.rm = TRUE),
    venous_count = sum(sample_source == "V", na.rm = TRUE),
    arterial_percent = round_half_up((arterial_count / total_samples) * 100),
    venous_percent = round_half_up((venous_count / total_samples) * 100)
  )
#- 6.1.2: Create the summary sentence ----
sample_composition_text <- paste0(
  "Of the ", sample_summary$total_samples, " samples run, ",
  sample_summary$arterial_count, " (", round_half_up(sample_summary$arterial_percent), "%) were arterial and ",
  sample_summary$venous_count, " (", round_half_up(sample_summary$venous_percent), "%) were venous."
)
#+ 6.2: Rates and n's of PGD grade ----
#- 6.2.1: Compute the counts and percentages of each PGD grade ----
postop_PGD_grade_ISHLT_counts <- clinical_metadata %>%
  group_by(postop_PGD_grade_ISHLT) %>%
  summarise(n = n()) %>%
  mutate(percentage = n / sum(n) * 100)
#- 6.2.2: Create and display results sentence ----
pgd_grades_sentence <- paste("Of the", sum(postop_PGD_grade_ISHLT_counts$n), "patients,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "N"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "N"]), "%)"), "had no PGD,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Mild"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Mild"]), "%)"), "had mild PGD,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Moderate"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Moderate"]), "%)"), "had moderate PGD, and",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Severe"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Severe"]), "%)"), "had severe PGD.")
#+ 6.3: Manuscript sentences summary ----
cat(
  "\n",
  strrep("=", 60), "\n",
  "MANUSCRIPT SENTENCES FOR COPY-PASTE\n",
  strrep("=", 60), "\n",
  "\n",
  "\033[1;31mSentence for methods on sample types:\033[0m\n",  # Bold red header
  "\033[3;31m", sample_composition_text, "\033[0m\n",  # Italicized red sentence
  "\n",
  "\033[1;32mSentence for results on PGD grades:\033[0m\n",  # Bold green header
  "\033[3;32m", pgd_grades_sentence, "\033[0m\n",  # Italicized green sentence
  "\n",
  strrep("=", 60), "\n",
  "\n"
)
