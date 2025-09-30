### MetaboAnalystR Network Visualization
### Adapted from existing enrichment network plotting functions
### Simplified to work directly with MetaboAnalystR/mummichog outputs

#' Build Network from MetaboAnalystR Results
#'
#' This function creates network graph data from MetaboAnalystR mummichog results
#' without requiring KEGG compound fetching. Uses pathway p-values and hit counts
#' to create a simplified network visualization.
#'
#' @param csv_file Path to the mummichog pathway enrichment CSV file
#' @param edge_thresh Numeric threshold for creating edges based on p-value similarity (default 0.3)
#' @param max_pathways Maximum number of top pathways to include (default 20)
#' @param seed Integer seed for reproducible layout (default 123)
#'
#' @return A list containing graph data suitable for plot_enrichment_network
#'
#' @export
build_metaboanalyst_network <- function(csv_file, edge_thresh = 0.3, max_pathways = 20, seed = 123) {
  
  # Load required libraries
  library(igraph)
  library(dplyr)
  
  # Set seed for reproducibility
  set.seed(seed)
  
  # Read the mummichog results
  if (!file.exists(csv_file)) {
    stop("CSV file not found: ", csv_file)
  }
  
  pathway_results <- read.csv(csv_file, stringsAsFactors = FALSE)
  
  # Check required columns (MetaboAnalystR format)
  required_cols <- c("Hits.sig", "Expected", "P.Fisher.")
  missing_cols <- setdiff(required_cols, names(pathway_results))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Calculate enrichment factor (observed/expected)
  pathway_results$enrichment_factor <- pathway_results$Hits.sig / pmax(pathway_results$Expected, 0.1)
  pathway_results$neg_log_p <- -log10(pmax(pathway_results$P.Fisher., 1e-10))
  pathway_results$p.value <- pathway_results$P.Fisher.
  
  # Use row names as pathway names
  pathway_results$pathway_name <- rownames(pathway_results)
  pathway_results$pathway_ID <- rownames(pathway_results)
  
  # Filter and select top pathways
  filtered_df <- pathway_results %>%
    filter(!is.na(enrichment_factor) & !is.na(neg_log_p) & p.value < 0.1) %>%
    arrange(p.value) %>%
    head(max_pathways)
  
  if (nrow(filtered_df) == 0) {
    stop("No significant pathways found (p < 0.1)")
  }
  
  cat("Building network with", nrow(filtered_df), "pathways\n")
  
  # Create edges based on p-value similarity (simplified approach)
  # Pathways with similar p-values are connected
  pathway_pairs <- expand.grid(
    pathway1 = filtered_df$pathway_ID,
    pathway2 = filtered_df$pathway_ID,
    stringsAsFactors = FALSE
  ) %>%
    filter(pathway1 < pathway2) # Only upper triangle to avoid duplicates
  
  # Calculate similarity based on p-values and enrichment factors
  similarities <- apply(pathway_pairs, 1, function(pair) {
    p1_data <- filtered_df[filtered_df$pathway_ID == pair[1], ]
    p2_data <- filtered_df[filtered_df$pathway_ID == pair[2], ]
    
    # Similarity based on p-value proximity and enrichment factor proximity
    p_sim <- 1 - abs(p1_data$neg_log_p - p2_data$neg_log_p) / max(filtered_df$neg_log_p)
    enrich_sim <- 1 - abs(p1_data$enrichment_factor - p2_data$enrichment_factor) / max(filtered_df$enrichment_factor)
    
    # Combined similarity
    return((p_sim + enrich_sim) / 2)
  })
  
  # Create edge list for similarities above threshold
  edges_df <- data.frame(
    from = pathway_pairs$pathway1,
    to = pathway_pairs$pathway2,
    weight = similarities,
    stringsAsFactors = FALSE
  ) %>%
    filter(weight >= edge_thresh)
  
  # Prepare nodes data frame with correct column names for plotting
  nodes_df <- filtered_df %>%
    select(pathway_ID, pathway_name, enrichment_factor, neg_log_p, p.value) %>%
    mutate(
      Name = pathway_name,  # For plot labels
      size_val = pmin(enrichment_factor, 5),  # Cap size for visualization
      p_val = p.value
    ) %>%
    distinct()
  
  # Create igraph object
  if (nrow(edges_df) > 0) {
    g <- graph_from_data_frame(edges_df, directed = FALSE, vertices = nodes_df)
  } else {
    # If no edges, create a graph with only vertices
    g <- graph_from_data_frame(data.frame(from = character(0), to = character(0)), 
                               directed = FALSE, vertices = nodes_df)
  }
  
  cat("Network created with", vcount(g), "nodes and", ecount(g), "edges\n")
  
  # Return data in format expected by plot_enrichment_network
  return(list(
    graph = g,
    nodes = nodes_df,
    edges = edges_df
  ))
}

#' Plot MetaboAnalystR Network
#'
#' Simplified wrapper around plot_enrichment_network for MetaboAnalystR results
#'
#' @param csv_file Path to the mummichog pathway enrichment CSV file
#' @param save_path Optional file path to save the plot
#' @param plot_title Optional title for the plot
#' @param edge_thresh Threshold for edge creation (default 0.3)
#' @param max_pathways Maximum pathways to include (default 20)
#' @param ... Additional arguments passed to plot_enrichment_network
#'
#' @return ggplot2 object
#'
#' @export
plot_metaboanalyst_network <- function(csv_file, save_path = NULL, plot_title = "MFN Pathway Network", 
                                       edge_thresh = 0.3, max_pathways = 20, ...) {
  
  # Source the plotting function if not already loaded
  if (!exists("plot_enrichment_network")) {
    source("plot_enrichment_network.R")
  }
  
  # Build network data
  graph_data <- build_metaboanalyst_network(csv_file, edge_thresh, max_pathways)
  
  # Create plot
  plot <- plot_enrichment_network(
    graph_data = graph_data,
    save_path = save_path,
    plot_title = plot_title,
    p_limits = c(0.001, 0.1),  # Adjust for mummichog p-values
    ...
  )
  
  return(plot)
}