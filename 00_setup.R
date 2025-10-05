# Purpose: global setup (packages, options, paths, seed)
# Data are NOT included. Scripts can run on simulated schema-compatible data.

required_pkgs <- c(
  "tidyverse","here","janitor","skimr","lme4","lmerTest",
  "ordinal","emmeans","broom","broom.mixed","GGally","car","writexl"
)
to_install <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")

invisible(lapply(required_pkgs, library, character.only = TRUE))

set.seed(123)
options(stringsAsFactors = FALSE)
theme_set(theme_minimal())

# Project paths
PATH_DATA   <- here::here("data")            # empty; add data locally if allowed
PATH_OUT    <- here::here("results")         # outputs go here
PATH_FIGS   <- here::here("figs")
dir.create(PATH_OUT, showWarnings = FALSE, recursive = TRUE)
dir.create(PATH_FIGS, showWarnings = FALSE, recursive = TRUE)
