
# classify industries into major CES groups using Census codes from 2012 NAICS
ind_census_ces <- function(x) {
  case_when(
    x %in% seq(170, 290) ~ "Missing - Agriculture",
    x %in% seq(370, 490) ~ "Mining, Logging and Construction",
    x %in% seq(570, 690) ~ "Transportation, Warehousing, and Utilities",
    x == 770 ~ "Mining, Logging and Construction",
    x %in% seq(1070, 2390) ~ "Non-Durable Goods",
    x %in% seq(2470, 3980) ~ "Durable Goods",
    x == 3990 ~ "Missing - Manufacturing",
    x %in% seq(4070, 4590) ~ "Wholesale Trade",
    x %in% seq(4670, 5790) ~ "Retail Trade",
    x %in% seq(6070, 6390) ~ "Transportation, Warehousing, and Utilities",
    x %in% seq(6470, 6780) ~ "Information",
    x %in% seq(6870, 6990) ~ "Finance and Insurance",
    x %in% seq(7070, 7190) ~ "Real Estate and Rental and Leasing",
    x %in% seq(7270, 7490) ~ "Professional, Scientific, and Technical Services",
    x == 7570 ~ "Management of Companies and Enterprises",
    x %in% seq(7580, 7790) ~
      "Administrative and Support and Waste Management and Remediation Services",
    x %in% seq(7860, 7890) ~ "Educational Services",
    x %in% seq(7970, 8470) ~ "Health Care and Social Assistance",
    x %in% seq(8560, 8590) ~ "Arts, Entertainment, and Recreation",
    x %in% seq(8660, 8690) ~ "Accommodation and Food Services",
    x %in% seq(8770, 9290) ~ "Other Services",
    x %in% seq(9370, 9590) ~ "Missing - Public Administration",
    x %in% seq(9670, 9870) ~ "Missing - Military"
  )
}

# given appropriate microdata, calculate rr by wage status industry group
# produces a state X period data set with three replacement rates
rr_by_industry_group <- function(data, x) {
  name <- sym(paste0("wage_status_", x))
  
  data %>%
    group_by(state_fips, wage_status := !!name) %>% 
    summarise(
      across(contains("rr_"),
             ~ Hmisc::wtd.quantile(.x, weights = weight, probs = 0.5))
    ) %>% 
    ungroup() %>% 
    pivot_longer(matches("rr_")) %>% 
    mutate(period = as.numeric(str_sub(name, 4, 4))) %>% 
    select(-name) %>% 
    pivot_wider(
      id_cols = c("state_fips", "period"), 
      names_from = "wage_status",
      names_glue = paste0("rr_{wage_status}", x)
    )
}

# download and read SM CES flat file
download_sm <- function(x) {
  system(paste0(
    "cd data_raw && wget -q -N https://download.bls.gov/pub/time.series/sm/sm.",
    x
  ))
  vroom(paste0("data_raw/sm.", x))
}

# aggregate CES employment by industry group identifiers
emp_by_industry_group <- function(data, x) {
  name <- sym(paste0("wage_status_", x))
  
  data %>%
    filter(!is.na(!!name)) %>% 
    group_by(seasonal, state_fips, month_date, wage_status := !!name) %>% 
    summarise(
      value = sum(value)
    ) %>% 
    ungroup() %>% 
    pivot_wider(
      id_cols = c("seasonal", "state_fips", "month_date", "seasonal"), 
      names_from = "wage_status",
      names_glue = paste0("emp_{wage_status}", x)
    )
}

# state_names <- tidycensus::fips_codes %>% 
#   transmute(
#     state_abb = state,
#     state_name,
#     state_fips = as.numeric(state_code) 
#   ) %>% 
#   distinct() %>% 
#   filter(state_fips <= 56)