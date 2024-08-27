# -----------
# Functions belonging to 01_preprocessing_bulk_RNA.Rmd
# -----------
filterBulkGenes <- function(bulkData, hgncData, ncData, ensemblID = TRUE) {
  cat("----\n")
  
  # Determine column in bulk data containing gene names
  colHGNC <- ifelse(ensemblID, "ensembl_gene_id", "symbol")
  cat("Column in bulk data containing the gene names:", colHGNC, "\nInitial gene count:", nrow(bulkData), "\n")
  
  # Filter genes not recognized by HGNC and add ensembl_gene_id/symbol column
  bulkFilterHGNC <- bulkData %>%
    dplyr::filter(.data[[colHGNC]] %in% hgncData[[colHGNC]]) %>%
    dplyr::left_join(dplyr::select(hgncData, ensembl_gene_id, symbol), by = colHGNC) %>%
    dplyr::select(ensembl_gene_id, symbol, everything())
  cat("Gene count present in HGNC data:", nrow(bulkFilterHGNC), "(removed", nrow(bulkData) - nrow(bulkFilterHGNC), "genes)\n")
  
  # Filter non-coding RNA genes
  bulkFilterNC <- bulkFilterHGNC %>%
    dplyr::filter(!(symbol %in% ncData$Symbol))
  cat("Gene count of coding RNA genes:", nrow(bulkFilterNC), "(removed", nrow(bulkFilterHGNC) - nrow(bulkFilterNC), "non-coding RNA genes)\n")

  return(bulkFilterNC)
}

pcaPlot <- function(cpm, title = "PCA of bulk RNA-seq data") {
  pca <- prcomp(t(cpm), scale = TRUE)

  p <- ggplot(as.data.frame(pca$x), aes(x = PC1, y = PC2)) +
    geom_point() +
    labs(title = title,
         x = paste0("PC1: ", round(summary(pca)$importance[2,1] * 100, 2), "% Variance"),
         y = paste0("PC2: ", round(summary(pca)$importance[2,2] * 100, 2), "% Variance")) +
    theme_minimal()
  
  print(p)
}
