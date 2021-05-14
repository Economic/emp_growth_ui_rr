library(tidyverse)
library(lubridate)
library(vroom)
library(epiextractr)
library(hrbrthemes)
library(fixest)

# load misc functions used later
source("source/helpers.R")

# create state X month covid case/death rates
# outputs: covid_cases_clean
source("source/clean_covid.R")

# use 2019 ORG to classify groups industries by wages
# outputs: industry_wage_classifications
source("source/classify_industries_wages.R")

# create state X period dataset of industry group replacement rates
# based on GNV data
# inputs: industry_wage_classifications
# outputs: state_period_rrs
source("source/clean_gnv.R")

# create state X month dataset of industry group emp & rrs, periods
# inputs: 
#   industry_wage_classifications
#   state_period_rrs
#   covid_cases_clean
# outputs:
#   ces_final 
#   regready_sa.csv 
#   regready_nsa.csv
source("source/clean_ces.R")

# analyze data
source("source/analysis.R")