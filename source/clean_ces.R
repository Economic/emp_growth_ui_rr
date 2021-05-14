# define CES major industry groups
ces_major_industries <- industry_wage_classifications %>% 
  mutate(ces_major_industry = 1)

ces_raw <- download_sm("data.0.Current") %>% 
  filter(year >= 2019) %>% 
  select(series_id, year, period, value) %>% 
  # merge series information
  inner_join(download_sm("series"), by = "series_id") %>% 
  mutate(
    state_fips = as.numeric(state_code),
    month = as.numeric(str_sub(period, 2, 3))
  ) %>% 
  # keep only states, monthly data
  filter(
    area_code == "00000" & state_fips >= 1 & state_fips <= 56,
    month <= 12
  ) %>% 
  mutate(month_date = ym(paste0(year, "m", month))) %>% 
  # merge industry names
  inner_join(download_sm("industry"), by = "industry_code") %>% 
  rename(ces_ind_name = industry_name)
  
# extract CES emp for major industries + overall private
ces_emp <- ces_raw %>% 
  filter(data_type_code == "01") %>% 
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

emp_priv <- ces_emp %>% 
  filter(ces_ind_name == "Total Private") %>% 
  select(seasonal, state_fips, month_date, emp_priv = value)

emp_2019_priv <- emp_priv %>% 
  filter(year(month_date) == 2019 & seasonal == "U") %>% 
  group_by(state_fips) %>% 
  summarize(emp_2019_priv = mean(emp_priv))

emp_rest <- ces_emp %>% 
  filter(ces_ind_name == "Accommodation and Food Services") %>% 
  select(seasonal, state_fips, month_date, emp_rest = value)

# extract AHE for certain sectors
ces_ahe <- ces_raw %>% 
  filter(
    data_type_code == "03",
    ces_ind_name == "Leisure and Hospitality"
  ) %>% 
  select(
    seasonal,
    state_fips,
    month_date,
    ahe_lh = value
  )

# identify and drop states with missing industries used in industry groups
all_ces_good_states <- ces_emp %>% 
  distinct(seasonal, state_fips, ces_ind_name) %>% 
  count(seasonal, state_fips) %>% 
  filter(n == 18) %>% 
  select(-n)

all_ces_filtered <- ces_emp %>% 
  inner_join(all_ces_good_states, by = c("seasonal", "state_fips"))

# select key covid vars
covid_vars <- covid_cases_clean %>% 
  select(state_fips, month_date, new_cases_num, new_cases_rate)

# merge everything
ces_to_join <- list(
  emp_priv, 
  emp_rest, 
  emp_by_industry_group(all_ces_filtered, 25),
  emp_by_industry_group(all_ces_filtered, 33),
  ces_ahe
)

ces_final <- map(ces_to_join, ~ .x) %>% 
  reduce(full_join, by = c("seasonal", "state_fips", "month_date")) %>% 
  full_join(emp_2019_priv, by = "state_fips") %>% 
  # merge covid case counts
  inner_join(covid_vars, by = c("state_fips", "month_date")) %>% 
  # define UI regimes
  mutate(period = case_when(
    month_date <= ym("2020m3") ~ 0,
    month_date >= ym("2020m4") & month_date <= ym("2020m7") ~ 1,
    month_date >= ym("2020m8") & month_date <= ym("2020m12") ~ 2,
    month_date >= ym("2021m1") ~ 3
  )) %>% 
  # merge replacement rates
  inner_join(state_period_rrs, by = c("state_fips", "period")) %>% 
  # final clean up
  mutate(year = year(month_date), month = month(month_date)) %>% 
  relocate(
    seasonal, 
    state_fips,
    year,
    month, 
    month_date, 
    period,
    matches("emp_\\w25"),
    matches("r_\\w25"),
    matches("emp_\\w33"),
    matches("r_\\w33"),
    emp_priv,
    emp_rest,
    ahe_lh
  ) %>% 
  arrange(seasonal, state_fips, month_date) %>% 
  rename(
    emp_M50 = emp_M25,
    rr_M50 = rr_M25
  )

# save separate SA and NSA files
ces_final %>% 
  filter(seasonal == "S") %>% 
  write_csv("data_clean/regready_sa.csv")

ces_final %>% 
  filter(seasonal == "U") %>% 
  write_csv("data_clean/regready_nsa.csv")

# clean workspace
rm(
  ces_major_industries, 
  ces_raw,
  ces_emp, 
  ces_ahe,
  emp_priv,
  emp_rest,
  emp_2019_priv,
  all_ces_good_states,
  all_ces_filtered,
  ces_to_join,
  covid_vars
)