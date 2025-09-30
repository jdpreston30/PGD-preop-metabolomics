#' Build Enrichment Network Graph Data
#'
#' This function performs the analysis portion of enrichment network creation,
#' including KEGG compound fetching, Jaccard similarity calculations, and graph construction.
#'
#' @param enrich_df A data frame containing enrichment results. Must include `pathway_ID`, `pathway_name`, `enrichment_factor`, and either `p_value` or `neg_log_p`.
#' @param edge_thresh Numeric threshold for edge inclusion based on Jaccard similarity of compounds (default 0.10).
#' @param prefer_hsa Logical indicating whether to prefer human (hsa) KEGG pathway IDs when fetching compounds (default TRUE).
#' @param term2compound_override Optional data frame to override pathway-to-compound mappings. Must have columns `pathway_ID` and `compound_id` (default NULL).
#' @param seed Integer seed for reproducible layout (default 123).
#'
#' @return A list containing:
#' \describe{
#'   \item{graph}{The igraph object representing the network.}
#'   \item{nodes}{Data frame of node attributes.}
#'   \item{edges}{Data frame of edge attributes.}
#'   \item{term2compound}{Data frame mapping pathways to compounds.}
#' }
#'
#' @examples
#' \dontrun{
#'   # Assuming enrich_df is a data frame with required columns
#'   graph_data <- build_enrichment_network(enrich_df)
#' }
build_enrichment_network <- function(
    enrich_df,
    edge_thresh = 0.10,
    prefer_hsa = TRUE,
    term2compound_override = NULL,
    seed = 123
) {
  
  # Load required libraries
  library(KEGGREST)
  library(igraph)
  library(dplyr)
  
  # Set seed for reproducibility
  set.seed(seed)
  
  # Validate input data frame
  required_cols <- c("pathway_ID", "pathway_name", "enrichment_factor")
  missing_cols <- setdiff(required_cols, names(enrich_df))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Handle p-value column (either p_value or neg_log_p)
  if ("p_value" %in% names(enrich_df)) {
    enrich_df$neg_log_p <- -log10(enrich_df$p_value)
  } else if (!"neg_log_p" %in% names(enrich_df)) {
    stop("Either 'p_value' or 'neg_log_p' column must be present")
  }
  
  # Filter to significant pathways (remove NA values)
  filtered_df <- enrich_df %>%
    filter(!is.na(enrichment_factor) & !is.na(neg_log_p))
  
  if (nrow(filtered_df) == 0) {
    stop("No valid pathways after filtering")
  }
  
  # Build pathway-to-compound mapping
  if (!is.null(term2compound_override)) {
    term2compound <- term2compound_override
  } else {
    message("Fetching KEGG compound data for pathways...")
    
    # Prepare pathway IDs for KEGG querying
    pathway_ids <- unique(filtered_df$pathway_ID)
    
    # Convert pathway names to KEGG IDs if needed
    kegg_ids <- sapply(pathway_ids, function(pid) {
      # If already a KEGG ID (starts with map or hsa), use as is
      if (grepl("^(map|hsa)\\d{5}$", pid)) {
        return(pid)
      }
      
      # Otherwise, try to find KEGG ID by name
      # This is a simplified approach - in practice you might need more sophisticated matching
      tryCatch({
        # Search for pathway by name
        search_result <- keggFind("pathway", pid)
        if (length(search_result) > 0) {
          # Prefer human pathways if available
          if (prefer_hsa) {
            hsa_matches <- grep("^hsa", names(search_result))
            if (length(hsa_matches) > 0) {
              return(names(search_result)[hsa_matches[1]])
            }
          }
          return(names(search_result)[1])
        }
        return(pid) # Return original if no match found
      }, error = function(e) {
        warning("Could not find KEGG ID for pathway: ", pid)
        return(pid)
      })
    })
    
    # Fetch compounds for each pathway
    term2compound_list <- list()
    
    for (i in seq_along(kegg_ids)) {
      pathway_id <- pathway_ids[i]
      kegg_id <- kegg_ids[i]
      
      tryCatch({
        # Get pathway compounds from KEGG
        pathway_info <- keggGet(kegg_id)
        
        if (length(pathway_info) > 0 && !is.null(pathway_info[[1]]$COMPOUND)) {
          compounds <- names(pathway_info[[1]]$COMPOUND)
          
          term2compound_list[[i]] <- data.frame(
            pathway_ID = pathway_id,
            compound_id = compounds,
            stringsAsFactors = FALSE
          )
        }
      }, error = function(e) {
        warning("Could not fetch compounds for pathway: ", pathway_id, " (", kegg_id, ")")
      })
    }
    
    # Combine all pathway-compound mappings
    if (length(term2compound_list) > 0) {
      term2compound <- do.call(rbind, term2compound_list)
    } else {
      # If no compounds found, create dummy data to prevent errors
      warning("No compound data found. Creating network based on pathway names only.")
      term2compound <- data.frame(
        pathway_ID = pathway_ids,
        compound_id = paste0("dummy_", seq_along(pathway_ids)),
        stringsAsFactors = FALSE
      )
    }
  }
  
  # Calculate Jaccard similarity between pathways
  message("Calculating Jaccard similarities...")
  
  pathway_pairs <- expand.grid(
    pathway1 = unique(filtered_df$pathway_ID),
    pathway2 = unique(filtered_df$pathway_ID),
    stringsAsFactors = FALSE
  ) %>%
    filter(pathway1 < pathway2) # Only upper triangle to avoid duplicates
  
  similarities <- apply(pathway_pairs, 1, function(pair) {
    compounds1 <- term2compound$compound_id[term2compound$pathway_ID == pair[1]]
    compounds2 <- term2compound$compound_id[term2compound$pathway_ID == pair[2]]
    
    if (length(compounds1) == 0 || length(compounds2) == 0) {
      return(0)
    }
    
    # Jaccard similarity = intersection / union
    intersection <- length(intersect(compounds1, compounds2))
    union <- length(union(compounds1, compounds2))
    
    if (union == 0) {
      return(0)
    } else {
      return(intersection / union)
    }
  })
  
  # Create edge list for similarities above threshold
  edges_df <- data.frame(
    from = pathway_pairs$pathway1,
    to = pathway_pairs$pathway2,
    weight = similarities,
    stringsAsFactors = FALSE
  ) %>%
    filter(weight >= edge_thresh)
  
  # Create nodes data frame
  nodes_df <- filtered_df %>%
    select(pathway_ID, pathway_name, enrichment_factor, neg_log_p) %>%
    distinct()
  
  # Create igraph object
  if (nrow(edges_df) > 0) {
    g <- graph_from_data_frame(edges_df, directed = FALSE, vertices = nodes_df)
  } else {
    # If no edges, create a graph with only vertices
    g <- graph_from_data_frame(data.frame(from = character(0), to = character(0)), 
                               directed = FALSE, vertices = nodes_df)
  }
  
  message("Network created with ", vcount(g), " nodes and ", ecount(g), " edges")
  
  # Return all components
  return(list(
    graph = g,
    nodes = nodes_df,
    edges = edges_df,
    term2compound = term2compound
  ))
}