library(epiextractr)

load_org(2019) %>% 
  filter(wage > 0) %>%
  group_by(industry_code = ind12) %>% 
  summarize(
    wage_p50 = MetricsWeighted::weighted_quantile(wage, w = orgwgt, probs = 0.5),
    n = n(),
    emp = sum(orgwgt / 12),
  ) %>% 
  mutate(emp_share = emp / sum(emp)) %>% 
  arrange(wage_p50) %>% 
  mutate(cum_emp_share = cumsum(emp_share)) %>% 
  select(industry_code, wage_p50, n, emp_share, cum_emp_share) %>% 
  print(n = 100)