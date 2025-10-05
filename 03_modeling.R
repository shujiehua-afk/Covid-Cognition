# Purpose: fit LMM for continuous outcomes and CLMM for ordered outcomes; baseline-referenced contrasts
source("00_setup.R")
df_long <- readRDS(file.path(PATH_OUT,"panel_clean.rds"))

# Continuous outcomes (scores)
cont_vars <- names(df_long) %>% keep(~ startsWith(.x, "score_"))
# Ordered outcomes (severities)
ord_vars  <- c("severity_global","severity_memory","severity_attention","severity_exec")

# LMM loop + baseline vs m6/m12 contrasts
lmm_results <- purrr::map_dfr(cont_vars, function(v){
  fml <- as.formula(paste0(v, " ~ time_point + (1|id)"))
  fit <- lmer(fml, data = df_long, REML = FALSE)
  contr <- emmeans::emmeans(fit, "time_point") %>%
    contrast(method = "trt.vs.ctrl", ref = "baseline") %>%
    as.data.frame()
  broom::tidy(fit) %>%
    mutate(variable = v, result = "coef") %>%
    bind_rows(contr %>% mutate(variable = v, result = "contrast"))
})

# CLMM loop + latent mean contrasts
clmm_results <- purrr::map_dfr(ord_vars, function(v){
  fml <- as.formula(paste0(v, " ~ time_point + (1|id)"))
  fit <- ordinal::clmm(fml, data = df_long, Hess = TRUE)
  contr <- emmeans::emmeans(fit, "time_point", mode = "latent") %>%
    contrast(method = "trt.vs.ctrl", ref = "baseline") %>%
    as.data.frame()
  broom.mixed::tidy(fit) %>% 
    mutate(variable = v, result = "coef") %>%
    bind_rows(contr %>% mutate(variable = v, result = "contrast"))
})

saveRDS(lmm_results,  file.path(PATH_OUT,"lmm_results.rds"))
saveRDS(clmm_results, file.path(PATH_OUT,"clmm_results.rds"))
