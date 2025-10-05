# Purpose: quick EDA, correlation, collinearity flags; produce stakeholder-facing notes
source("00_setup.R")
df_long <- readRDS(file.path(PATH_OUT,"panel_clean.rds"))

# Baseline snapshot for screening (avoid repeated measures confounding simple screens)
df_base <- df_long %>% filter(time_point == "baseline")

# Descriptives
desc <- df_base %>% select(where(is.numeric)) %>% summary()
capture.output(desc, file = file.path(PATH_OUT,"descriptives_baseline.txt"))

# Correlation matrix among numeric scores
num_scores <- df_base %>% select(starts_with("score_"))
if (ncol(num_scores) >= 2) {
  ggcorr <- GGally::ggcorr(num_scores, label = TRUE)
  ggsave(file.path(PATH_FIGS,"corr_scores_baseline.png"), ggcorr, width=7, height=5, dpi=150)
}

# VIF for a provisional linear model (illustrative)
if (ncol(num_scores) >= 2) {
  df_base2 <- df_base %>% drop_na(all_of(colnames(num_scores)))
  if (nrow(df_base2) > 10) {
    lm_vif <- lm(score_a ~ ., data = df_base2 %>% select(-id))
    vif_tbl <- car::vif(lm_vif)
    write_writexl(as.data.frame(vif_tbl), file.path(PATH_OUT,"vif_provisional.xlsx"))
  }
}

# Stakeholder note (what to ask data owners)
cat(
  paste(
    "- Recommend confirming unique patient IDs across time points.\n",
    "- Provide data dictionary for severity scales (0–3 levels, ordered).\n",
    "- Consider collecting 'education_years' or similar covariate for adjustment.\n",
    "- High correlation among some scores; consider parsimony to reduce multicollinearity.\n"
  ),
  file = file.path(PATH_OUT,"stakeholder_requests.txt")
)
