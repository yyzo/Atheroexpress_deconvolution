#Extracts the patient IDs corresponding to the filter condition.
filterPatients <- function(patientData, filterCondition, columnPatientID){
  patientData %>%
    dplyr::filter({{filterCondition}}) %>%
    dplyr::select({{columnPatientID}}) %>%
    pull()
}