# Purpose: load/merge longitudinal data into a tidy panel; mark issues for collaborators
source("00_setup.R")

# Example schema (masked variable names):
keep_vars <- c(
  "id","severity_global","severity_memory","severity_attention","severity_exec",
  "score_a","score_b","score_c","score_d"
)

# Replace with local file names if you have access; otherwise simulate:
simulate_if_missing <- function(){
  n_id <- 120
  ids  <- sprintf("S%03d", 1:n_id)
  make_wave <- function(tp){
    tibble(
      id = ids,
      severity_global   = sample(0:3, n_id, TRUE),
      severity_memory   = sample(0:3, n_id, TRUE),
      severity_attention= sample(0:3, n_id, TRUE),
      severity_exec     = sample(0:3, n_id, TRUE),
      score_a = rnorm(n_id, 0, 1),
      score_b = rnorm(n_id, 0, 1),
      score_c = rnorm(n_id, 0, 1),
      score_d = rnorm(n_id, 0, 1),
      time_point = tp
    )
  }
  bind_rows(make_wave("baseline"), make_wave("m6"), make_wave("m12"))
}

if (all(file.exists(
  file.path(PATH_DATA,"baseline.csv"),
  file.path(PATH_DATA,"six_month.csv"),
  file.path(PATH_DATA,"twelve_month.csv")
))) {
  baseline   <- read.csv(file.path(PATH_DATA,"baseline.csv"))   %>% janitor::clean_names()
  six_month  <- read.csv(file.path(PATH_DATA,"six_month.csv"))  %>% janitor::clean_names()
  twelve_mon <- read.csv(file.path(PATH_DATA,"twelve_month.csv"))%>% janitor::clean_names()
  
  baseline   <- baseline  %>% select(any_of(c(keep_vars))) %>% mutate(time_point="baseline")
  six_month  <- six_month %>% select(any_of(c(keep_vars))) %>% mutate(time_point="m6")
  twelve_mon <- twelve_mon%>% select(any_of(c(keep_vars))) %>% mutate(time_point="m12")
  
  df_long <- bind_rows(baseline, six_month, twelve_mon)
} else {
  df_long <- simulate_if_missing()
}

# Basic hygiene checks to communicate with non-technical stakeholders:
# 1) ID consistency; 2) missingness; 3) impossible values.
issue_notes <- list()

# ID duplicates
dup_ids <- df_long %>% count(id, time_point) %>% filter(n > 1)
if (nrow(dup_ids) > 0) issue_notes$duplicate_ids <- dup_ids

# Missingness summary
miss_tbl <- skimr::skim(df_long) %>% as_tibble() %>% 
  select(skim_variable, n_missing, complete_rate)
write_writexl <- function(obj, path) try(writexl::write_xlsx(obj, path), silent=TRUE)
write_writexl(miss_tbl, file.path(PATH_OUT,"missingness_summary.xlsx"))

# Type harmonization
df_long <- df_long %>%
  mutate(
    time_point = factor(time_point, levels = c("baseline","m6","m12"), ordered = TRUE),
    across(starts_with("severity_"), ~ factor(.x, levels = 0:3, ordered = TRUE)),
    across(starts_with("score_"), as.numeric)
  )

saveRDS(df_long, file.path(PATH_OUT,"panel_clean.rds"))
