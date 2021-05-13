# define CES major industry groups
ces_major_industries <- industry_wage_classifications %>% 
  mutate(ces_major_industry = 1)

# extract CES emp for major industries + overall private
all_ces <- download_sm("data.0.Current") %>% 
  filter(year >= 2019) %>% 
  select(series_id, year, period, value) %>% 
  # merge series information
  inner_join(download_sm("series"), by = "series_id") %>% 
  mutate(
    state_fips = as.numeric(state_code),
    month = as.numeric(str_sub(period, 2, 3))
  ) %>% 
  # keep only states, monthly data, and employment level outcome
  filter(
    area_code == "00000" & state_fips >= 1 & state_fips <= 56,
    month <= 12,
    data_type_code == "01"
  ) %>% 
  mutate(month_date = ym(paste0(year, "m", month))) %>% 
  # merge industry names
  inner_join(download_sm("industry"), by = "industry_code") %>% 
  rename(ces_ind_name = industry_name) %>% 
  # classify major CES industries
  full_join(
    ces_major_industries, 
    by = "ces_ind_name"
  ) %>% 
  # keep only major CES industries or total private sector emp
  filter(ces_major_industry == 1 | industry_code == "05000000") %>% 
  select(
    seasonal,
    state_fips,
    month_date,
    value,
    ces_ind_name,
    ces_major_industry,
    matches("wage_")
  )

emp_priv <- all_ces %>% 
  filter(ces_ind_name == "Total Private") %>% 
  select(seasonal, state_fips, month_date, emp_priv = value)

emp_2019_priv <- emp_priv %>% 
  filter(year(month_date) == 2019 & seasonal == "U") %>% 
  group_by(state_fips) %>% 
  summarize(emp_2019_priv = mean(emp_priv))

emp_rest <- all_ces %>% 
  filter(ces_ind_name == "Accommodation and Food Services") %>% 
  select(seasonal, state_fips, month_date, emp_rest = value)

# identify and drop states with missing industries used in industry groups
all_ces_good_states <- all_ces %>% 
  distinct(seasonal, state_fips, ces_ind_name) %>% 
  count(seasonal, state_fips) %>% 
  filter(n == 18) %>% 
  select(-n)

all_ces_filtered <- all_ces %>% 
  inner_join(all_ces_good_states, by = c("seasonal", "state_fips"))

ces_to_join <- list(
  emp_priv, 
  emp_rest, 
  emp_by_industry_group(all_ces_filtered, 25),
  emp_by_industry_group(all_ces_filtered, 33)
)

ces_final <- map(ces_to_join, ~ .x) %>% 
  reduce(full_join, by = c("seasonal", "state_fips", "month_date")) %>% 
  full_join(emp_2019_priv, by = "state_fips") %>% 
  mutate(period = case_when(
    month_date <= ym("2020m3") ~ 0,
    month_date >= ym("2020m4") & month_date <= ym("2020m7") ~ 1,
    month_date >= ym("2020m8") & month_date <= ym("2020m12") ~ 2,
    month_date >= ym("2021m1") ~ 3
  )) %>% 
  inner_join(state_period_rrs, by = c("state_fips", "period"))

ces_final %>% 
  filter(seasonal == "S") %>% 
  write_csv("data_clean/regready_sa.csv")

ces_final %>% 
  filter(seasonal == "U") %>% 
  write_csv("data_clean/regready_nsa.csv")

rm(
  ces_major_industries, 
  all_ces, 
  emp_priv,
  emp_rest,
  emp_2019_priv,
  all_ces_good_states,
  all_ces_filtered,
  ces_to_join
)