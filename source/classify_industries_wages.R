# grab ORG private sector that match to desired CES industries
org_data <- load_org(2019) %>% 
  filter(wageotc > 0) %>%
  filter(cow1 == 4 | cow1 == 5) %>% 
  mutate(ces_ind_name = ind_census_ces(ind12)) %>% 
  filter(str_detect(ces_ind_name, "Missing - ") != 1)

# calculate emp shares by industry
industry_wage_emp_shares <- org_data %>% 
  group_by(ces_ind_name) %>% 
  summarize(
    wage_p50 = MetricsWeighted::weighted_quantile(wageotc, w = orgwgt, probs = 0.5),
    n = n(),
    emp = sum(orgwgt / 12),
  ) %>% 
  mutate(emp_share = emp / sum(emp)) %>% 
  arrange(wage_p50) %>% 
  mutate(cum_emp_share = cumsum(emp_share)) %>% 
  select(ces_ind_name, wage_p50, n, emp_share, cum_emp_share)

# define bottom/top third
industry_def_33 <- industry_wage_emp_shares %>% 
  mutate(wage_status_33 = case_when(
    cum_emp_share < 0.34 ~ "L",
    cum_emp_share > 0.68 ~ "H",
    TRUE ~ "M"
  )) %>% 
  select(ces_ind_name, wage_status_33)

# define bottom/top quarter
industry_def_25 <- industry_wage_emp_shares %>% 
  mutate(wage_status_25 = case_when(
    cum_emp_share < 0.25 ~ "L",
    cum_emp_share > 0.76 ~ "H",
    TRUE ~ "M"
  )) %>% 
  select(ces_ind_name, wage_status_25)

# all classifications
industry_wage_classifications <- industry_def_33 %>% 
  full_join(industry_def_25, by = "ces_ind_name")

# summary stats for each CES industry
org_data %>% 
  full_join(industry_wage_classifications, by = "ces_ind_name") %>% 
  group_by(ces_ind_name) %>% 
  summarize(
    wage_p50 = MetricsWeighted::weighted_quantile(wageotc, w = orgwgt, probs = 0.5),
    emp = sum(orgwgt / 12),
    across(matches("wage_status"), first)
  ) %>% 
  mutate(emp_share = emp / sum(emp)) %>% 
  arrange(wage_p50) %>% 
  mutate(cum_emp_share = cumsum(emp_share)) %>% 
  select(ces_ind_name, matches("wage_status"), wage_p50, matches("emp_share"))


# clean up 
rm(org_data, industry_wage_emp_shares, industry_def_33, industry_def_25)