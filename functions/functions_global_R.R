# ---- Functions
createDir <- function(path) {
  if (!file.exists(path)) {
    dir.create(path)
    print("Folder created.")
  } else {
    print("Folder already exists.")
  }
}

# ---- Figure themes
blueColorPal <- list("7" = c("#F8FBFF", "#C5DBEC", "#A0CAE2", "#6CACD5", "#4A97CA", "#1D71B5", "#0C5696"),
                     "5" = c("#F8FBFF", "#C5DBEC", "#6CACD5", "#1D71B5", "#0C5696"),
                     "4" = c("#F8FBFF", "#C5DBEC", "#6CACD5", "#1D71B5"),
                     "3" = c("#C5DBEC", "#6CACD5", "#1D71B5"),
                     "2" = c("#C5DBEC", "#1D71B5"))

rdBuColorPal7 <- c("#b2182b", "#ef8a62", "#fddbc7", "#f7f7f7", "#d1e5f0", "#67a9cf", "#2166ac")
heatmapPal <- circlize::colorRamp2(c(-1, -0.66, -0.33, 0, 0.33, 0.66, 1), rdBuColorPal7)

boxplotTheme <- function() {
  theme(plot.title = element_text(size = 10, face = "bold"),
        axis.title.y = element_text(size = 10, margin = margin(r = 6)),
        axis.text = element_text(size = 8),
        axis.text.x = element_text(angle = 45, hjust = 1, margin = margin(t = 3)),
        axis.text.y = element_text(margin = margin(r = 3)),
        axis.line = element_line(linewidth = 0.3),
        legend.title = element_text(size = 10, hjust = 0.5),
        legend.text = element_text(size = 8),
        legend.position = "top",
        legend.margin = margin(b = -1))
}
