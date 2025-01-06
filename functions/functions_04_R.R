# -----------
# Functions belonging to 04_analysis_cellular_deconvolution_predictions.Rmd
# -----------

library(magrittr)
cat("From functions_04_R.R: loaded magrittr library")

# < Loading Scaden cellular deconvolution predicitions >
getScadenPred <- function(pathScaden, fileBasePattern, nVersions, nRuns) {
  cat("Cellular deconvolution method: Scaden\n")
  
  if(length(nVersions) == 1) {
    basePath <- paste0(pathScaden, fileBasePattern, nVersions, "/", fileBasePattern, nVersions, "_n")
    cat("Loading", length(nRuns), "runs of one version:\n", basePath, "\n")
    
    return(loadAndProcessScaden(basePath, nRuns))
  } else {
    cat("Loading", length(nRuns), "runs of multiple versions:\n")
    allPreds <- list()
    
    for(i in seq_along(nVersions)) {
      version <- nVersions[i]
      basePath <- paste0(pathScaden, fileBasePattern, version, "/", fileBasePattern, version, "_n")
      cat(basePath, "\n")
      
      allPreds[[paste0("version", version)]] <- loadAndProcessScaden(basePath, nRuns)
    }
    
    return(allPreds)
  }
}

loadAndProcessScaden <- function(basePath, nRuns) {
  listWidePred <- list()
  listLongPred <- list()
  
  for(i in nRuns) {
    widePred <- read.delim(paste0(basePath, i), check.names = FALSE, row.names = 1) %>%
      dplyr::select(order(colnames(.))) %>%
      tibble::rownames_to_column("patient")
    
    longPred <- widePred %>%
      tidyr::pivot_longer(cols = -patient, names_to = "cellType", values_to = "proportion")
    
    listWidePred[[paste0("wideRun", i)]] <- widePred
    listLongPred[[paste0("longRun", i)]] <- longPred
  }
  
  avgLongPred <- listLongPred %>%
    purrr::reduce(~ dplyr::full_join(.x, .y, by = c("patient", "cellType"))) %>%
    dplyr::mutate(avgProportion = rowMeans(dplyr::select(., -patient, -cellType))) %>%
    dplyr::select(patient, cellType, avgProportion)
  
  avgWidePred <- avgLongPred %>%
    tidyr::pivot_wider(names_from = cellType, values_from = avgProportion)
  
  return(list(listWidePred = listWidePred, listLongPred = listLongPred, avgWidePred = avgWidePred, avgLongPred = avgLongPred))
}
