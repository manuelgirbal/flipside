library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

options(scipen=999)

data_1 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/a40c5db4-ab8a-4d71-930d-057fcaffbe17/data/latest")

data2_1 <- rawToChar(data_1$content)

data3_1 <- as_tibble(fromJSON(data2_1, flatten = TRUE))



data3_1 %>% 
  filter(VOTER == tolower("0x7609047ab9086f0b86147dfc7653f63e50f848d4"))
