library(tidyverse)

# data and some code directly from GNV replication package
# https://github.com/ganong-noel/ui_rep_rate
m_occs <- tribble(
  ~m_occ_code, ~m_occ_name,
  "00", "Managers",
  "01", "Managers",
  "02", "Managers",
  "03", "Managers",
  "04", "Managers",
  "47", "Sales & retail",
  "23", "Teachers",
  "36", "Medical assistants",
  "91", "Transport",
  "40", "Food service",
  "41", "Food service",
  "32", "Nurses & therapists",
  "10", "IT",
  "42", "Janitors",
  "62", "Construction",
  "54", "Receptionist"
)

m_inds <-  tribble(
  ~m_ind_name, ~m_ind_code,
  "Agriculture & forestry",  1,
  "Mining",  2,
  "Construction", 3,
  "Manufacturing", 4,
  "Wholesale & retail trade", 5,
  "Transportation & utilities",  6,
  "Information",   7,
  "Financial activities",  8,
  "Professional services",  9,
  "Educational & health services", 10,
  "Leisure & hospitality", 11,
  "Other services",   12,
  "Public administration",  13)

asec <- vroom("data_raw/ASEC_1719.csv.gz") %>%
  rename_with(tolower) %>% 
  select(year, serial, pernum, industry_full = ind)

gnv_data <- vroom("data_raw/wages_logit_weights_filtered.csv.gz") %>% 
  rename(
    replacement_rate_1 = replacement_rate,
    replacement_rate_2 = replacement_rate_FPUC,
    state_fips = fips 
  ) %>% 
  mutate(replacement_rate_3 = if_else(
    benefits_amount > 0,
    (benefits_amount + 300) / weekly_earnings,
    0)) %>% 
  mutate(two_digit_occ = as.character(two_digit_occ)) %>%
  full_join(m_occs, by = c(two_digit_occ = "m_occ_code")) %>%
  full_join(m_inds, by = c(two_digit_ind = "m_ind_code")) %>%
  inner_join(asec, by = c("year", "serial", "pernum"))

gnv_data %>%
  group_by(state_fips, m_ind_name) %>%
  summarise(
    across(contains("replacement_rate"),
               ~ Hmisc::wtd.quantile(.x, weights = weight, probs = 0.5)),
    n = n()
  ) %>% 
  write_csv("data_clean/state_industry_rr.csv")

break
  

gnv_data %>%
  mutate(ces_ind_name = ind_census_ces(industry_full)) %>% 
  group_by(new) %>%
  summarise(across(contains("replacement_rate"),
                   ~ Hmisc::wtd.quantile(.x, weights = weight, probs = 0.5))) %>% 
  arrange(desc(replacement_rate_2))



