ces_final_sa <- read_csv("data_clean/regready_sa.csv") 
ces_final_nsa <- read_csv("data_clean/regready_nsa.csv")

regready <- bind_rows(ces_final_sa, ces_final_nsa)

regready_mean <- regready %>% 
  filter(!is.na(emp_L25)) %>% 
  group_by(seasonal, month_date) %>% 
  summarize(
    period = first(period),
    mean_rr_L25 = weighted.mean(rr_L25, w = emp_2019_priv),
    mean_rr_H25 = weighted.mean(rr_H25, w = emp_2019_priv)
  ) %>% 
  mutate(state_fips = 0)

regready_with_mean <- bind_rows(regready, regready_mean)

plot <- regready_with_mean %>% 
  filter(seasonal == "S") %>% 
  ggplot() +
  geom_point(aes(x = month_date, y = rr_L25), alpha = 0.2) +
  geom_point(
    aes(x = month_date, y = mean_rr_L25), 
    color = "red", 
    size = 3, 
    alpha = 0.8
  ) +
  labs(
    x = "", 
    y = "",
    title = "Replacement rate for the bottom 25% industries, by state"
  ) +
  expand_limits(y = c(0, 2.25)) +
  theme_ipsum_rc()

plot
ggsave(
  "figures/rr_bottom25.pdf", 
  device = cairo_pdf, 
  width = 12, 
  height = 9
)

plot <- regready_with_mean %>% 
  filter(seasonal == "S") %>% 
  ggplot() +
  geom_point(aes(x = month_date, y = rr_H25), alpha = 0.2) +
  geom_point(
    aes(x = month_date, y = mean_rr_H25), 
    color = "red", 
    size = 3, 
    alpha = 0.8
  ) +
  labs(
    x = "", 
    y = "",
    title = "Replacement rate for the top 25% industries, by state"
  ) +
  expand_limits(y = c(0, 2.25)) +
  theme_ipsum_rc()

plot
ggsave(
  "figures/rr_top25.pdf", 
  device = cairo_pdf, 
  width = 12, 
  height = 9
)