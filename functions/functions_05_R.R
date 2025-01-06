# -----------
# Functions belonging to 05_clinical_correlations.Rmd
# -----------

sympFilter <- function(sympData, toFilter) {
  listSympDataFiltered <- list()
  
  for(col in toFilter) {
    sympDataFiltered <- sympData %>%
      filter(!is.na(!!rlang::sym(col)) & !!rlang::sym(col) != -888 & !!rlang::sym(col) != -999) %>%
      select(patient, cellType, proportion, !!rlang::sym(col))
    
    listSympDataFiltered[[col]] <- sympDataFiltered
  }
  return(listSympDataFiltered)
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