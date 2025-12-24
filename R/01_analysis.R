# WSL R packages
pkgs <- c("readr", "dplyr", "ggplot2", "tidyr")
to_install <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(to_install)) install.packages(to_install, repos="https://cloud.r-project.org")
invisible(lapply(pkgs, library, character.only = TRUE))

# R studio packages
library(readr)
library(dplyr)
library(ggplot2)

dir.create("reports", showWarnings = FALSE, recursive = TRUE)
df <- read_csv("data/processed/urban2015_clean.csv", show_col_types = FALSE)

# Headline metric: overall weighted percent (if Weight/Percent exist)
if (all(c("Percent", "Weight") %in% names(df))) {
  overall <- df %>%
    filter(!is.na(Percent), !is.na(Weight)) %>%
    summarise(
      n_rows = n(),
      sum_weight = sum(Weight),
      overall_weighted_percent = ifelse(sum(Weight) == 0, NA, 
                                        sum(Percent * Weight) / sum(Weight))
    )
  write_csv(overall, "reports/overall_weighted.csv")
}

# Plot 1: weighted percent by Region/Taxa/Year_Pred (if intermediate exists)
if (file.exists("data/processed/weighted_by_group.csv")) {
  grouped <- read_csv("data/processed/weighted_by_group.csv", 
                      show_col_types = FALSE)
  
  p1 <- grouped %>%
    filter(!is.na(weighted_percent)) %>%
    ggplot(aes(x = Year_Pred, y = weighted_percent)) +
    geom_line() +
    geom_point() +
    facet_grid(Region ~ Taxa, scales = "free_y") +
    labs(
      title = "Weighted Extinction Percent by Region and Taxa",
      x = "Prediction Year",
      y = "Weighted Percent"
    )
  
  ggsave("reports/fig_weighted_by_region_taxa.png", p1, width = 12, height = 8)
}

# Plot 2: threshold sensitivity
if (file.exists("data/processed/threshold_sensitivity.csv")) {
  thresh <- read_csv("data/processed/threshold_sensitivity.csv", 
                     show_col_types = FALSE)
  
  p2 <- thresh %>%
    filter(!is.na(weighted_mean_percent)) %>%
    ggplot(aes(x = Threshold, y = weighted_mean_percent)) +
    geom_line() +
    geom_point() +
    facet_wrap(~ Year_Pred) +
    labs(
      title = "Threshold Sensitivity of Weighted Mean Percent",
      x = "Threshold",
      y = "Weighted Mean Percent"
    )
  
  ggsave("reports/fig_threshold_sensitivity.png", p2, width = 12, height = 7)
}

cat("Done. See reports/ for outputs.\n")



