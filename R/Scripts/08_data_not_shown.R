#* 8: Data Not Shown
#+ 8.0: Sample Processing Time
#- 8.0.1: Compute Elapsed Minutes
processing_time <- sample_type %>%
  mutate(
    sample_dt = as.POSIXct(paste(as.Date(sample_date), format(sample_time, "%H:%M:%S")), tz = "UTC"),
    processing_dt = as.POSIXct(paste(as.Date(processing_date), format(processing_time, "%H:%M:%S")), tz = "UTC"),
    processing_dt = if_else(processing_dt < sample_dt,
      processing_dt + days(1),
      processing_dt
    ),
    elapsed_min = as.numeric(difftime(processing_dt, sample_dt, units = "mins")),
    elapsed_hr = elapsed_min / 60
  ) %>%
  select(Patient, Sample, sample_dt, processing_dt, elapsed_min, elapsed_hr) %>%
  summarise(
    min_hr = min(elapsed_hr, na.rm = TRUE),
    max_hr = max(elapsed_hr, na.rm = TRUE),
    mean_hr = mean(elapsed_hr, na.rm = TRUE)
  )
#+ 8.1: Percent of samples arterial versus venous
#- 8.1.1: Generate sample composition summary 
sample_summary <- sample_type %>%
  summarise(
    total_samples = n(),
    arterial_count = sum(sample_source == "A", na.rm = TRUE),
    venous_count = sum(sample_source == "V", na.rm = TRUE),
    arterial_percent = round_half_up((arterial_count / total_samples) * 100),
    venous_percent = round_half_up((venous_count / total_samples) * 100)
  )
#- 8.1.2: Create the summary sentence 
sample_composition_text <- paste0(
  "Of the ", sample_summary$total_samples, " samples run, ",
  sample_summary$arterial_count, " (", round_half_up(sample_summary$arterial_percent), "%) were arterial and ",
  sample_summary$venous_count, " (", round_half_up(sample_summary$venous_percent), "%) were venous."
)
#+ 8.2: Rates and n's of PGD grade 
#- 8.2.1: Compute the counts and percentages of each PGD grade 
postop_PGD_grade_ISHLT_counts <- clinical_metadata %>%
  group_by(postop_PGD_grade_ISHLT) %>%
  summarise(n = n()) %>%
  mutate(percentage = n / sum(n) * 100)
#- 8.2.2: Create and display results sentence 
pgd_grades_sentence <- paste("Of the", sum(postop_PGD_grade_ISHLT_counts$n), "patients,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "N"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "N"]), "%)"), "had no PGD,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Mild"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Mild"]), "%)"), "had mild PGD,",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Moderate"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Moderate"]), "%)"), "had moderate PGD, and",
    postop_PGD_grade_ISHLT_counts$n[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Severe"], 
    paste0("(", round_half_up(postop_PGD_grade_ISHLT_counts$percentage[postop_PGD_grade_ISHLT_counts$postop_PGD_grade_ISHLT == "Severe"]), "%)"), "had severe PGD.")
#- 8.2.3: Create processing time sentence
processing_time_sentence <- paste0(
  "Sample processing times ranged from ", round(processing_time$min_hr, 2), " to ", round(processing_time$max_hr, 2), 
  " hours (mean = ", round(processing_time$mean_hr, 2), " hours)."
)
#+ 8.3: Manuscript sentences summary 
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
  "\033[1;34mSentence for methods on sample processing times:\033[0m\n",  # Bold blue header
  "\033[3;34m", processing_time_sentence, "\033[0m\n",  # Italicized blue sentence
  "\n",
  strrep("=", 60), "\n",
  "\n"
)
#+ 8.4: Write manuscript sentences to Word document
#- 8.4.1: Create output directory if it doesn't exist
output_dir <- "Outputs/data_not_shown"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}
#- 8.4.2: Create Word document with manuscript sentences
doc <- officer::read_docx()
doc <- doc %>%
  officer::body_add_par("Data Not Shown - Manuscript Sentences", style = "heading 1") %>%
  officer::body_add_par("") %>%
  officer::body_add_par("Sample Composition", style = "heading 2") %>%
  officer::body_add_par(sample_composition_text) %>%
  officer::body_add_par("") %>%
  officer::body_add_par("PGD Grade Distribution", style = "heading 2") %>%
  officer::body_add_par(pgd_grades_sentence) %>%
  officer::body_add_par("") %>%
  officer::body_add_par("Sample Processing Times", style = "heading 2") %>%
  officer::body_add_par(processing_time_sentence) %>%
  officer::body_add_par("") %>%
  officer::body_add_par("Mummichog Parameters", style = "heading 2")
#- 8.4.3: Save the document
print(doc, target = file.path(output_dir, "data_not_shown.docx"))
cat("\nWord document saved to:", file.path(output_dir, "data_not_shown.docx"), "\n")
#+ 8.5: Mummichog Parameters (preserved for reference)
#! see analysis_parameters.md in Outputs/mummichog