# ---------------------------------------------------------
# Functions belonging to Analysis_prediction_Scaden.Rmd
# ---------------------------------------------------------

getLongProportions <- function(basePathPrediction, nSimulations = seq_len(10)) {
  library(magrittr)
  
  listPred <- list()
  listLong <- list()
  
  for(n in nSimulations) {
    if(n < 10) {
      path <- paste0(basePathPrediction, "0", n)
    } else {
      path <- paste0(basePathPrediction, n)
    }
    
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

shapiroTestCustom <- function(data) {
  celltypes <- levels(data$Celltype)
  
  shapiroResults <- list()
  
  for (celltype in celltypes) {
    subset <- data %>%
      dplyr::filter(Celltype == celltype)
    
    shapiroRes <- shapiro.test(subset$`Average proportion`)
    
    shapiroResults[[celltype]] <- list(
      pValue = shapiroRes$p.value,
      normalityPass = shapiroRes$p.value >= 0.05
    )
  }
  
  print("Can normality be assumed?")
  
  for (name in names(shapiroResults)) {
    if (shapiroResults[[name]]$normalityPass == TRUE) {
      cat(name, ": Yes (", shapiroResults[[name]]$pValue,")\n")
    } else {
      cat(name, ": No (", shapiroResults[[name]]$pValue,")\n")
    }
  }
  
  return(shapiroResults)
}


celltypesQQPlot <- function(data) {
  celltypes <- levels(data$Celltype)
  
  for(celltype in celltypes) {
    subset <- data %>%
      dplyr::filter(Celltype == celltype)
    
    p <- ggpubr::ggqqplot(subset$`Average proportion`) +
      labs(title = paste("Q-Q Plot for", celltype))
    
    print(p)
  }
}

leveneTestCustom <- function(data) {
  celltypes <- levels(data$Celltype)
  
  leveneResults <- list()
  
  for (celltype in celltypes) {
    subset <- data %>%
      dplyr::filter(Celltype == celltype)
    
    leveneRes <- car::leveneTest(`Average proportion` ~ Group, data = subset)
    
    leveneResults[[celltype]] <- list(
      pValue = leveneRes[1,3],
      equalityPass = leveneRes[1,3] >= 0.05)
  }
  
  print("Are the variances between the groups homogeneous?")
  
  for (name in names(leveneResults)) {
    if (leveneResults[[name]]$equalityPass == TRUE) {
      cat(name, ": Yes (", leveneResults[[name]]$pValue,")\n")
    } else {
      cat(name, ": No (", leveneResults[[name]]$pValue,")\n")
    }
  }
  
  return(invisible(leveneResults))
}

kruskalTestCustom <- function(data) {
  celltypes <- levels(data$Celltype)
  
  kruskalResults <- list()
  
  for (celltype in celltypes) {
    subset <- data %>%
      dplyr::filter(Celltype == celltype)
    
    kruskalRes <- kruskal.test(`Average proportion` ~ Group, data = subset)
    
    kruskalResults[[celltype]] <- list(
      pValue = kruskalRes$p.value,
      significancePass = kruskalRes$p.value <= 0.05)
  }
  
  print("Is there a significant difference between the groups?")
  
  for (name in names(kruskalResults)) {
    if (kruskalResults[[name]]$significancePass == TRUE) {
      cat(name, ": Yes (", kruskalResults[[name]]$pValue,")\n")
    } else {
      cat(name, ": No (", kruskalResults[[name]]$pValue,")\n")
    }
  }
  
  return(kruskalResults)
}

dunnTestCustom <- function(data) {
  celltypes <- levels(data$Celltype)
  
  dunnResults <- tibble()
  
  for (celltype in celltypes) {
    subset <- data %>%
      dplyr::filter(Celltype == celltype)
    
    dunnRes <- FSA::dunnTest(`Average proportion` ~ Group, data = subset, method = "bonferroni")
    
    dunnResults <- dunnResults %>%
      rbind(dunnRes$res %>%
              as_tibble() %>%
              mutate(Celltype = celltype,
                     Significant = ifelse(P.adj <=0.05, TRUE, FALSE)))
    
  }
  
  return(dunnResults %>%
           select(Celltype, everything()))
  
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
