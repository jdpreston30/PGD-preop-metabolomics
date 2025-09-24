#* 1: PCA and PLS-DA Analysis
#+ 1.1: Run PCA on UFT data ----
uft_pca <- make_PCA(UFT_filtered, method = "PCA", show_patient_labels = TRUE, label_size = 2)



# #+ 1.4: Post-hoc demographic analysis of PCA clusters
#   #- 1.4.1: Create PCA cluster groups based on clear PC1 separation


