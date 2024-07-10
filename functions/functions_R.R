# ---------------------------------------------------------
# Functions belonging to Analysis_prediction_Scaden.Rmd
# ---------------------------------------------------------

getLongProportions <- function(basePathPrediction, nSimulations = seq_len(10)) {
  library(magrittr)
  
  listPred <- list()
  listLong <- list()
  
  for(n in nSimulations) {
    path <- paste0(basePathPrediction, n)
    file <- read.delim(path, check.names = FALSE) 
    
    colnames(file)[1] <- "Patient"
    file <- file[, order(colnames(file))] %>%
      dplyr::select("Patient", everything())
    
    listPred[[paste0("pred", n)]] <- file

    longFile <- file %>%
      pivot_longer(cols = -Patient,
                   names_to = "Celltype",
                   values_to = "Proportion")

    listLong[[paste0("longPred", n)]] <- longFile
  }
  return(c(listPred, listLong))
}

getAvgProportions <- function(nameList, nSimulations = seq_len(10)) {
  avgProp <- as.data.frame(nameList[["longPred1"]][1:2])

  for(n in nSimulations) {
    longFile <- nameList[[paste0("longPred", n)]]
    avgProp <- dplyr::left_join(avgProp,
                                longFile,
                                by = c("Patient", "Celltype"))
  }

  avgProp$`Average proportion` <- rowMeans(avgProp[, 3:ncol(avgProp)])
  avgProp <- select(avgProp, Patient, Celltype, `Average proportion`)

  return(avgProp)
}

exportAvgProportions <- function(file, 
                                 celltypeCol = "Celltype", 
                                 avgPropCol = "Average proportion", 
                                 exportPath) {
  wideFile <- tidyr::pivot_wider(file,
                                 names_from = celltypeCol,
                                 values_from = avgPropCol)
  
  readr::write_excel_csv(wideFile, exportPath)
}

matchSymptomGroup <- function(patientData,
                              cellProportionsData,
                              columnSymptoms,
                              toMatch) {
  library(magrittr)
  
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
ownTheme <- function() {
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_text(size = 13, hjust = 0.5, margin = margin(t = 15)),
        axis.title.y = element_text(size = 13, hjust = 0.5, margin = margin(r = 15)),
        panel.grid.minor.y = element_line(color = "gray", linewidth = 0.5),
        legend.title = element_text(size = 13),
        legend.text = element_text(size = 11)
  )
}

fillBoxplot <- function(data, pattern, col, nSimulations = seq_len(10), nCelltypes, legendName = col, labels = NULL) {
  p <- ggplot(data, aes(x = reorder(Celltype, `Average proportion`), y = `Average proportion`)) +
    geom_boxplot(aes(fill = as.factor(!!rlang::sym(col))), 
                 position = position_dodge(width = 0.8), width = 0.5, alpha = 0.5) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 1, by = 0.1)) +
    labs(title = paste0("Cellular deconvolution average prediction: ", pattern),
         subtitle = paste("Cell types:", nCelltypes,
                          "\nTotal runs:", length(nSimulations))) +
    ylab("Relative average proportion") +
    xlab("Celltype") +
    theme_ipsum_rc(grid="Y") +
    ownTheme()
  
  if(is.null(labels)) {
    p <- p + scale_fill_viridis(discrete = TRUE, name = legendName)
  } else {
    p <- p + scale_fill_viridis(discrete = TRUE, name = legendName, labels = labels)
  }
  
  return(p)
}

sympFilter <- function(sympData, toFilter) {
  listSympDataFiltered <- list()
  
  for(col in toFilter) {
    sympDataFiltered <- sympData %>%
      filter(!is.na(!!rlang::sym(col)) & !!rlang::sym(col) != -888 & !!rlang::sym(col) != -999) %>%
      select(Patient, Celltype, `Average proportion`, !!rlang::sym(col))
    
    listSympDataFiltered[[col]] <- sympDataFiltered
  }
  return(listSympDataFiltered)
}
