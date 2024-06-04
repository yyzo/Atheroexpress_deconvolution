matchSymptomGroup <- function(patientData,
                              cellProportionsData,
                              columnSymptoms,
                              toMatch) {
  purrr::map(toMatch, ~ {
    patientData %>%
      dplyr::filter(!!rlang::sym(columnSymptoms) == .x) %>%
      dplyr::inner_join(cellProportionsData, by = "Patient") %>%
      dplyr::select(Patient,
                    Celltype,
                    `Average proportion`,
                    !!rlang::sym(columnSymptoms))
  })
}

ownMinimalTheme <- function() {
  theme(
    plot.title = element_text(face = "bold", size = 18),
    #Modify x- and y-axes
    axis.title.x = element_text(size = 16, margin = margin(t = 5)),
    axis.title.y = element_text(size = 16, margin = margin(r = 10)),
    axis.text.x = element_text(
      angle = 60,
      vjust = 1,
      hjust = 1,
      size = 13
    ),
    axis.text.y = element_text(size = 13),
    axis.ticks.y = element_blank(),
    #Modify panel
    panel.background = element_blank(),
    panel.grid.major.y = element_line(color = "lightgray", linewidth = 0.8),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.y = element_line(color = "lightgray", linewidth = 0.1),
    panel.grid.minor.x = element_blank(),
    #Modify legend
    legend.key.size = unit(1, "cm"),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 13)
  )
}

# CHANGE IT SO THAT IT ONLY DEPENDS ON IDENTS OF SEURAT OBJECT
highlightCellsUMAP <- function(seuratObject,
                               cellTypesColumn,
                               regexPattern,
                               title) {
  matchCells <- grep(regexPattern, levels(seuratObject@meta.data[[cellTypesColumn]]), value = TRUE)
  
  cellsToHighlight <- list()
  
  for (cellType in matchCells) {
    cellsToHighlight[[cellType]] <- Seurat::WhichCells(seuratObject, idents = cellType)
  }
  
  if (length(cellsToHighlight) > 0) {
    highlightColors <- scales::hue_pal()(length(cellsToHighlight))
    
    p <- Seurat::DimPlot(
      seuratObject,
      reduction = "umap",
      cells.highlight = cellsToHighlight,
      cols.highlight = highlightColors,
      cols = "grey",
      raster = FALSE
    ) +
      labs(title = title) +
      guides(color = guide_legend(ncol = 1))
    
    return(p)
  } else{
    print("No match to pattern")
  }
}

highlightCompartmentUMAP <- function(seuratObject, 
                                     cellTypesVector, 
                                     title) {
  cellsToHighlight <- list()
  
  for (cellType in cellTypesVector) {
    cellsToHighlight[[cellType]] <- Seurat::WhichCells(seuratObject, idents = cellType)
  }
  
  highlightColors <- scales::hue_pal()(length(cellsToHighlight))
  
  p <- Seurat::DimPlot(
    seuratObject,
    reduction = "umap",
    cells.highlight = cellsToHighlight,
    cols.highlight = highlightColors,
    cols = "grey",
    raster = FALSE
  ) +
    labs(title = title) +
    guides(color = guide_legend(ncol = 2))
  
  return(p)
}
