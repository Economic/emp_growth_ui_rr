# data and some code directly from GNV replication package
# https://github.com/ganong-noel/ui_rep_rate

# load raw ASEC used in GNV to grab full industry codes
asec <- vroom("data_raw/ASEC_1719.csv.gz") %>%
  rename_with(tolower) %>% 
  select(year, serial, pernum, industry_full = ind)

# define period specific replacement rates for individuals
gnv_data <- vroom("data_raw/wages_logit_weights_filtered.csv.gz") %>% 
  mutate(
    rr_0 = replacement_rate,
    rr_1 = replacement_rate_FPUC,
    rr_2 = replacement_rate,
    state_fips = fips 
  ) %>% 
  mutate(rr_3 = if_else(
    benefits_amount > 0,
    (benefits_amount + 300) / weekly_earnings,
    0)) %>% 
  # merge asec industry codes & desired CES industry groups
  inner_join(asec, by = c("year", "serial", "pernum")) %>% 
  mutate(ces_ind_name = ind_census_ces(industry_full)) %>% 
  inner_join(industry_wage_classifications, by = "ces_ind_name") %>% 
  select(
    state_fips,
    weight,
    matches("rr_|wage_status")
  )

# aggregate replacement rates to industry group level
state_period_rrs <- full_join(
  rr_by_industry_group(gnv_data, 25), 
  rr_by_industry_group(gnv_data, 33), 
  by = c("state_fips", "period")
) 

rm(asec, gnv_data)
