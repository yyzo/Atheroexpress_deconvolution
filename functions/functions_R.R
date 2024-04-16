matchSymptomGroup <- function(patientData, cellProportionsData, columnSymptoms, toMatch) {
  purrr::map(toMatch, ~ {
    patientData %>%
      dplyr::filter(!!rlang::sym(columnSymptoms) == .x) %>%
      dplyr::inner_join(cellProportionsData, by = "Patient") %>%
      dplyr::select(Patient, Celltype, `Average proportion`, !!rlang::sym(columnSymptoms))
  })
}

ownMinimalTheme <- function(){
  theme(plot.title = element_text(face = "bold",
                                  size = 18),
        #Modify x- and y-axes
        axis.title.x = element_text(size = 16,
                                    margin = margin(t = 5)),
        axis.title.y = element_text(size = 16,
                                    margin = margin(r = 10)),
        axis.text.x = element_text(angle=60, vjust = 1, hjust = 1, size = 13),
        axis.text.y = element_text(size = 13),
        axis.ticks.y = element_blank(),
        #Modify panel
        panel.background = element_blank(),
        panel.grid.major.y = element_line(color = "lightgray",
                                          linewidth = 0.8),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_line(color = "lightgray",
                                          linewidth = 0.1),
        panel.grid.minor.x = element_blank(),
        #Modify legend
        legend.key.size = unit(1, "cm"),
        legend.title = element_text(size = 16),
        legend.text = element_text(size = 13))
}
