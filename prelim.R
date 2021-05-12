library(tidyverse)
library(lubridate)
library(vroom)

ind_census_ces <- function(x) {
  case_when(
    x %in% seq(170, 290) ~ "Missing - Ag",
    x %in% seq(370, 490) ~ "Mining and Logging",
    x %in% seq(570, 690) ~ "Transportation, Warehousing, and Utilities",
    x == 770 ~ "Construction",
    x %in% seq(1070, 2390) ~ "Non-Durable Goods",
    x %in% seq(2470, 3980) ~ "Durable Goods",
    x %in% seq(4070, 4590) ~ "Wholesale Trade",
    x %in% seq(4670, 5790) ~ "Retail Trade",
    x %in% seq(6070, 6390) ~ "Transportation, Warehousing, and Utilities",
    x %in% seq(6470, 6780) ~ "Information",
    x %in% seq(6870, 6992) ~ "Finance and Insurance",
    x %in% seq(7071, 7190) ~ "Real Estate and Rental and Leasing",
    x %in% seq(7270, 7490) ~ "Professional, Scientific, and Technical Services",
    x == 7570 ~ "Management of Companies and Enterprises",
    x %in% seq(7580, 7790) ~
      "Administrative and Support and Waste Management and Remediation Services",
    x %in% seq(7860, 7890) ~ "Educational Services",
    
  )
}

# # A tibble: 34 x 3
# 6 10000000      Mining and Logging                               47
# 7 15000000      Mining, Logging and Construction                 51
# 8 20000000      Construction                                     48
# 10 31000000      Durable Goods                                    49
# 11 32000000      Non-Durable Goods                                49
# 13 41000000      Wholesale Trade                                  51
# 14 42000000      Retail Trade                                     51
# 15 43000000      Transportation, Warehousing, and Utilities       51
# 16 50000000      Information                                      50
# 17 55000000      Financial Activities                             51
# 18 55520000      Finance and Insurance                            45
# 19 55530000      Real Estate and Rental and Leasing               48
# 20 60000000      Professional and Business Services               51
# 21 60540000      Professional, Scientific, and Technical Serv…    49
# 22 60550000      Management of Companies and Enterprises          45
# 23 60560000      Administrative and Support and Waste Managem…    49
# 24 65000000      Education and Health Services                    51
# 25 65610000      Educational Services                             51
# 26 65620000      Health Care and Social Assistance                49
# 27 70000000      Leisure and Hospitality                          51
# 28 70710000      Arts, Entertainment, and Recreation              49
# 29 70720000      Accommodation and Food Services                  49
# 30 80000000      Other Services                                   51
# 31 90000000      Government                                       51
# 32 90910000      Federal Government                               51
# 33 90920000      State Government                                 50
# 34 90930000      Local Government                                 50


