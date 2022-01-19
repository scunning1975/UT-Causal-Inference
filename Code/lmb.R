# install.packages("tidyverse")
# install.packages("haven")
# install.packages("estimatr")

library(tidyverse)
library(haven)
library(estimatr)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

lmb_data <- read_data("lmb-data.dta")

lmb_subset <- lmb_data %>% 
  filter(lagdemvoteshare>.48 & lagdemvoteshare<.52)

lm_1 <- lm_robust(score ~ lagdemocrat, data = lmb_subset, clusters = id)
lm_2 <- lm_robust(score ~ democrat, data = lmb_subset, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat, data = lmb_subset, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)

#using all data (note data used is lmb_data, not lmb_subset)

lm_1 <- lm_robust(score ~ lagdemocrat, data = lmb_data, clusters = id)
lm_2 <- lm_robust(score ~ democrat, data = lmb_data, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat, data = lmb_data, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)

lmb_data <- lmb_data %>% 
  mutate(demvoteshare_c = demvoteshare - 0.5)

lm_1 <- lm_robust(score ~ lagdemocrat + demvoteshare_c, data = lmb_data, clusters = id)
lm_2 <- lm_robust(score ~ democrat + demvoteshare_c, data = lmb_data, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat + demvoteshare_c, data = lmb_data, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)

lm_1 <- lm_robust(score ~ lagdemocrat*demvoteshare_c, 
                  data = lmb_data, clusters = id)
lm_2 <- lm_robust(score ~ democrat*demvoteshare_c, 
                  data = lmb_data, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat*demvoteshare_c, 
                  data = lmb_data, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)

lmb_data <- lmb_data %>% 
  mutate(demvoteshare_sq = demvoteshare_c^2)

lmb_data <- lmb_data %>% 
  mutate(lagdemvoteshare_c = lagdemvoteshare - 0.5)

lmb_data <- lmb_data %>% 
  mutate(lagdemvoteshare_sq = lagdemvoteshare_c^2)


lm_1 <- lm_robust(score ~ lagdemocrat*lagdemvoteshare_c + lagdemocrat*lagdemvoteshare_sq, 
                  data = lmb_data, clusters = id)
lm_2 <- lm_robust(score ~ democrat*demvoteshare_c + democrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat*demvoteshare_c + lagdemocrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)

lmb_data %>% 
  filter(demvoteshare > .45 & demvoteshare < .55) %>%
  mutate(demvoteshare_sq = demvoteshare_c^2)

lm_1 <- lm_robust(score ~ lagdemocrat*demvoteshare_c + lagdemocrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)
lm_2 <- lm_robust(score ~ democrat*demvoteshare_c + democrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat*demvoteshare_c + lagdemocrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)


#aggregating the data
categories <- lmb_data$lagdemvoteshare

demmeans <- split(lmb_data$score, cut(lmb_data$lagdemvoteshare, 100)) %>% 
  lapply(mean) %>% 
  unlist()

agg_lmb_data <- data.frame(score = demmeans, lagdemvoteshare = seq(0.01,1, by = 0.01))

#plotting
lmb_data <- lmb_data %>% 
  mutate(gg_group = case_when(lagdemvoteshare > 0.5 ~ 1, TRUE ~ 0))
         
ggplot(lmb_data, aes(lagdemvoteshare, score)) +
  geom_point(aes(x = lagdemvoteshare, y = score), data = agg_lmb_data) +
  stat_smooth(aes(lagdemvoteshare, score, group = gg_group), method = "lm", 
              formula = y ~ x + I(x^2)) +
  xlim(0,1) + ylim(0,100) +
  geom_vline(xintercept = 0.5)

ggplot(lmb_data, aes(lagdemvoteshare, score)) +
  geom_point(aes(x = lagdemvoteshare, y = score), data = agg_lmb_data) +
  stat_smooth(aes(lagdemvoteshare, score, group = gg_group), method = "loess") +
  xlim(0,1) + ylim(0,100) +
  geom_vline(xintercept = 0.5)

ggplot(lmb_data, aes(lagdemvoteshare, score)) +
  geom_point(aes(x = lagdemvoteshare, y = score), data = agg_lmb_data) +
  stat_smooth(aes(lagdemvoteshare, score, group = gg_group), method = "lm") +
  xlim(0,1) + ylim(0,100) +
  geom_vline(xintercept = 0.5)



smooth_dem0 <- lmb_data %>% 
  filter(democrat == 0) %>% 
  select(score, demvoteshare)
smooth_dem0 <- as_tibble(ksmooth(smooth_dem0$demvoteshare, smooth_dem0$score, 
                                 kernel = "box", bandwidth = 0.1))


smooth_dem1 <- lmb_data %>% 
  filter(democrat == 1) %>% 
  select(score, demvoteshare) %>% 
  na.omit()
smooth_dem1 <- as_tibble(ksmooth(smooth_dem1$demvoteshare, smooth_dem1$score, 
                                 kernel = "box", bandwidth = 0.1))

ggplot() + 
  geom_smooth(aes(x, y), data = smooth_dem0) +
  geom_smooth(aes(x, y), data = smooth_dem1) +
  geom_vline(xintercept = 0.5)
  
rdr <- rdrobust(y = lmb_data$score,
                x = lmb_data$demvoteshare, c = 0.5)
summary(rdr)


DCdensity(lmb_data$demvoteshare, cutpoint = 0.5)

density <- rddensity(lmb_data$demvoteshare, c = 0.5)
rdplotdensity(density, lmb_data$demvoteshare)





DCdensity(lmb_data$demvoteshare, cutpoint = 0.5)

density <- rddensity(lmb_data$demvoteshare, c = 0.5)
rdplotdensity(density, lmb_data$demvoteshare)
