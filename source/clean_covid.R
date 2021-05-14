# state resident populations from 2020 census
# https://www2.census.gov/programs-surveys/decennial/2020/data/apportionment/apportionment-2020-table02.xlsx

state_pops <- tribble(
  ~state_name, ~pop_2020,
  "Alabama", 5024279,
  "Alaska", 733391,
  "Arizona", 7151502,
  "Arkansas", 3011524,
  "California", 39538223,
  "Colorado", 5773714,
  "Connecticut", 3605944,
  "Delaware", 989948,
  "District of Columbia", 689545,
  "Florida", 21538187,
  "Georgia", 10711908,
  "Hawaii", 1455271,
  "Idaho", 1839106,
  "Illinois", 12812508,
  "Indiana", 6785528,
  "Iowa", 3190369,
  "Kansas", 2937880,
  "Kentucky", 4505836,
  "Louisiana", 4657757,
  "Maine", 1362359,
  "Maryland", 6177224,
  "Massachusetts", 7029917,
  "Michigan", 10077331,
  "Minnesota", 5706494,
  "Mississippi", 2961279,
  "Missouri", 6154913,
  "Montana", 1084225,
  "Nebraska", 1961504,
  "Nevada", 3104614,
  "New Hampshire", 1377529,
  "New Jersey", 9288994,
  "New Mexico", 2117522,
  "New York", 20201249,
  "North Carolina", 10439388,
  "North Dakota", 779094,
  "Ohio", 11799448,
  "Oklahoma", 3959353,
  "Oregon", 4237256,
  "Pennsylvania", 13002700,
  "Rhode Island", 1097379,
  "South Carolina", 5118425,
  "South Dakota", 886667,
  "Tennessee", 6910840,
  "Texas", 29145505,
  "Utah", 3271616,
  "Vermont", 643077,
  "Virginia", 8631393,
  "Washington", 7705281,
  "West Virginia", 1793716,
  "Wisconsin", 5893718,
  "Wyoming", 576851,
)

state_frame <- expand_grid(
  state_name = state_pops$state_name,
  month_date = seq(ym("2019m1"), ym("2021m4"), by = "month")
)
  
# cumulative cases and deaths from NYT
# https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv
covid_cases_clean <- read_csv("data_raw/us-states.csv") %>% 
  mutate(
    state_fips = as.numeric(fips),
    month_date = ym(paste0(year(date), month(date)))
  ) %>% 
  group_by(state_fips, month_date) %>% 
  summarize(
    across(cases|deaths, max),
    state_name = first(state)
  ) %>% 
  ungroup() %>% 
  right_join(state_frame, by = c("state_name", "month_date")) %>% 
  group_by(state_name) %>% 
  mutate(state_fips = max(state_fips, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(across(cases|deaths, ~ if_else(is.na(.), 0, .))) %>% 
  arrange(state_fips, month_date) %>% 
  inner_join(state_pops, by = "state_name") %>% 
  transmute(
    state_fips,
    month_date,
    cum_cases_num = cases,
    cum_deaths_num = deaths,
    pop_2020,
    cum_cases_rate = cum_cases_num / pop_2020,
    cum_deaths_rate = cum_deaths_num / pop_2020
  ) %>% 
  group_by(state_fips) %>% 
  mutate(
    new_cases_num = cum_cases_num - lag(cum_cases_num, order_by = month_date),
    new_cases_rate = new_cases_num / pop_2020
  )



covid_cases_clean %>% 
  ggplot(aes(
    x = month_date, 
    y = new_cases_rate, 
    group = state_fips,
    color = as_factor(state_fips)
  )) +
  geom_line() +
  scale_colour_viridis_d(begin = 0.2, end = 0.8, option = "magma") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    y = "Cases per 2020 resident population",
    x = "",
    title = "Cumulative Covid-19 cases by state and month"
  ) +
  expand_limits(y = c(0, 0.05)) +
  theme_ipsum_rc() +
  theme(
    legend.position="none",
    axis.title.y = element_text(size = rel(1.2))
  )
  
rm(state_pops, state_frame)