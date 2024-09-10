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

# < Loading BayesPrism cellular deconvolution predictions >
getBayesPrismPred <- function(pathBayesPrism, fileBasePattern, nVersions) {
  cat("Cellular deconvolution method: BayesPrism\n")
  
  if(length(nVersions) == 1) {
    path <- paste0(pathBayesPrism, fileBasePattern, nVersions, ".rdata")
    cat("Loading only one version:", path, "\n")
    
    return(loadAndProcessBayesPrism(path))
  } else {
    cat("Loading", length(nVersions), "versions:\n")
    listPreds <- list()
    
    for(i in seq_along(nVersions)) {
      version <- nVersions[i]
      path <- paste0(pathBayesPrism, fileBasePattern, version, ".rdata")
      cat(path, "\n")
      
      listPreds[[paste0("version", version)]] <- loadAndProcessBayesPrism(path)
    }
    return(listPreds)
  }
}

loadAndProcessBayesPrism <- function(path) {
  bp <- get(load(path))
  widePred <- BayesPrism::get.fraction(bp = bp, which.theta = "final", state.or.type = "type") %>%
    as.data.frame() %>%
    tibble::rownames_to_column("patient")
  
  longPred <- widePred %>%
    tidyr::pivot_longer(cols = -patient, names_to = "cellType", values_to = "proportion")
  
  return(list(widePred = widePred, longPred = longPred))
}
