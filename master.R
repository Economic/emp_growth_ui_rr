library(tidyverse)
library(lubridate)
library(vroom)
library(epiextractr)
library(hrbrthemes)

# load misc functions used later
source("helpers.R")

# use 2019 ORG to classify groups industries by wages
# outputs: industry_wage_classifications
source("classify_industries_wages.R")

# create state X period dataset of industry group replacement rates
# based on GNV data
# inputs: industry_wage_classifications
# outputs: state_period_rrs
source("clean_gnv.R")

# create state X month dataset of industry group emp & rrs, periods
# inputs: industry_wage_classifications, state_period_rrs
# outputs: ces_final, regready_sa.csv regready_nsa.csv
source("clean_ces.R")

# analyze data
source("analysis.R")