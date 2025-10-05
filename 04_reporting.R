# Purpose: produce tables and one illustrative figure (simulated)
source("00_setup.R")

lmm_results  <- readRDS(file.path(PATH_OUT,"lmm_results.rds"))
clmm_results <- readRDS(file.path(PATH_OUT,"clmm_results.rds"))

# Tidy exports
writexl::write_xlsx(
  list(
    "lmm_results"  = lmm_results,
    "clmm_results" = clmm_results
  ),
  path = file.path(PATH_OUT,"model_outputs.xlsx")
)

# Example figure: time trends using simulated means (no real data)
sim_plot <- tibble(
  time_point = factor(c("baseline","m6","m12"), levels=c("baseline","m6","m12"), ordered=TRUE),
  score_a_mean = c(0.0, 0.3, 0.5)
) %>%
  ggplot(aes(time_point, score_a_mean, group=1)) +
  geom_line() + geom_point(size=2) +
  labs(title="Illustrative trend (simulated)", y="Estimated mean of score_a", x=NULL)
ggsave(file.path(PATH_FIGS,"example_trend.png"), sim_plot, width=6, height=4, dpi=150)

# Session info
capture.output(sessionInfo(), file = file.path(PATH_OUT,"sessionInfo.txt"))

