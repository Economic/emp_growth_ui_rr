
# download and read SM CES flat file
download_sm <- function(x) {
  system(paste0(
    "cd data_raw && wget -q -N https://download.bls.gov/pub/time.series/sm/sm.",
    x
  ))
  vroom(paste0("data_raw/sm.", x))
}

all_ces <- download_sm("data.0.Current") %>% 
  filter(year >= 2019) %>% 
  select(series_id, year, period, value) %>% 
  inner_join(download_sm("series"), by = "series_id") %>% 
  filter(data_type_code == "01") %>% 
  inner_join(download_sm("state"), by = "state_code") %>% 
  # keep only states
  mutate(
    state_fips = as.numeric(state_code),
    month = as.numeric(str_sub(period, 2, 3))
  ) %>% 
  filter(
    area_code == "00000" & state_fips >= 1 & state_fips <= 56,
    month <= 12
  ) %>% 
  mutate(month_date = ym(paste0(year, "m", month))) %>% 
  select(
    series_id, year, month, state_fips, state_name, month_date, industry_code, seasonal
  ) %>% 
  inner_join(download_sm("industry"), by = "industry_code")
 
all_ces %>% 
  filter(year == 2021 & seasonal == "S" & month == 3) %>% 
  #filter(str_sub(industry_code, 3) == "000000" & str_sub(industry_code, 2, 2) != "0") %>% 
  count(industry_code, industry_name) %>% 
  print(n=Inf) 