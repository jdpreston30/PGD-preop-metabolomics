#* 1: PCA and PLS-DA Analysis ----
#+ 1.1: Run PCA on UFT data ----
uft_plsda_tier <- make_PCA(
  UFT_filtered %>% select(-severe_PGD), 
  method = "PLSDA", 
  ellipse_colors = c("Severe" = "#D8919A", "No PGD" = "#87A6C7", "Non-Severe" = "#9CAF88"), 
  point_colors = c("Severe" = "#800017", "No PGD" = "#113d6a", "Non-Severe" = "#4A5D23"), 
  show_patient_labels = FALSE, 
  label_size = 2
)

uft_plsda_severe <- make_PCA(
  UFT_filtered %>% select(-PGD_grade_tier), 
  method = "PLSDA", 
  show_patient_labels = FALSE, 
  label_size = 2
)

# Save plots as 5x5 PNG at 300 DPI
ggsave("uft_plsda_tier.png", plot = uft_plsda_tier$plot, width = 5, height = 5, dpi = 300, units = "in", bg = "white")
ggsave("uft_plsda_severe.png", plot = uft_plsda_severe$plot, width = 5, height = 5, dpi = 300, units = "in", bg = "white")

# #+ 1.4: Post-hoc demographic analysis of PCA clusters
#   #- 1.4.1: Create PCA cluster groups based on clear PC1 separation


