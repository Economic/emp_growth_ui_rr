all_data <- bind_rows(
  read_csv("data_clean/regready_sa.csv"), 
  read_csv("data_clean/regready_nsa.csv")
)

Drr <- all_data %>% 
  filter(period == 3 | period == 2) %>% 
  distinct(state_fips, period, rr_L25) %>% 
  pivot_wider(
    state_fips, 
    names_from = period, 
    values_from = rr_L25, 
    names_prefix = "rr"
  ) %>% 
  mutate(Drr = rr3 - rr2) %>% 
  select(state_fips, Drr)

regready <- all_data %>% 
  filter(!is.na(emp_L25)) %>% 
  filter(month_date >= ym("2020m8")) %>% 
  mutate(across(matches("^emp_"), log, .names = "log_{.col}")) %>% 
  inner_join(Drr, by = "state_fips") %>% 
  mutate(time = time_length(interval(ym("2021m1"), month_date), unit = "month")) %>% 
  filter(seasonal == "U") %>% 
  mutate(Drr = 1/0.6*Drr) %>% 
  mutate(post = if_else(month_date >= ym("2021m1"), 1, 0))

dl_model <- feols(
  log_emp_L25 ~ i(Drr, time, -1) + log(emp_priv) + log(new_cases_num) | state_fips + time, 
  data = regready,
  weights = regready$emp_2019_priv,
  cluster = "state_fips"
)
summary(dl_model)
plot_priv <- coefplot(dl_model, main = "with controls log(emp_priv) + log(new_cases_num)")

dd_model <- feols(
  log_emp_L25 ~ i(Drr, post, 0) + log(emp_priv) + log(new_cases_num) | state_fips + time, 
  data = regready,
  weights = regready$emp_2019_priv,
  cluster = "state_fips"
)
summary(dd_model)


break



# 
# regready_mean <- regready %>% 
#   filter(!is.na(emp_L25)) %>% 
#   group_by(seasonal, month_date) %>% 
#   summarize(
#     period = first(period),
#     mean_rr_L25 = weighted.mean(rr_L25, w = emp_2019_priv),
#     mean_rr_H25 = weighted.mean(rr_H25, w = emp_2019_priv)
#   ) %>% 
#   mutate(state_fips = 0)
# 
# regready_with_mean <- bind_rows(regready, regready_mean)
# 
# plot <- regready_with_mean %>% 
#   filter(seasonal == "S") %>% 
#   ggplot() +
#   geom_point(aes(x = month_date, y = rr_L25), alpha = 0.2) +
#   geom_point(
#     aes(x = month_date, y = mean_rr_L25), 
#     color = "red", 
#     size = 3, 
#     alpha = 0.8
#   ) +
#   labs(
#     x = "", 
#     y = "",
#     title = "Replacement rate for the bottom 25% industries, by state"
#   ) +
#   expand_limits(y = c(0, 2.25)) +
#   theme_ipsum_rc()
# 
# plot
# ggsave(
#   "figures/rr_bottom25.pdf", 
#   device = cairo_pdf, 
#   width = 12, 
#   height = 9
# )
# 
# plot <- regready_with_mean %>% 
#   filter(seasonal == "S") %>% 
#   ggplot() +
#   geom_point(aes(x = month_date, y = rr_H25), alpha = 0.2) +
#   geom_point(
#     aes(x = month_date, y = mean_rr_H25), 
#     color = "red", 
#     size = 3, 
#     alpha = 0.8
#   ) +
#   labs(
#     x = "", 
#     y = "",
#     title = "Replacement rate for the top 25% industries, by state"
#   ) +
#   expand_limits(y = c(0, 2.25)) +
#   theme_ipsum_rc()
# 
# plot
# ggsave(
#   "figures/rr_top25.pdf", 
#   device = cairo_pdf, 
#   width = 12, 
#   height = 9
# )