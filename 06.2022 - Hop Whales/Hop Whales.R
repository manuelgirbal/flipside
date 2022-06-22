# Are whales choosing Hop to go to L2s? Or are they choosing the native bridges? 
# Compare Hop vs the native bridges for Polygon, Optimism, and Arbitrum over the following metrics: unique users on each, frequency of use, and the average amount of assets moved on each?

library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

#Disabling scientific notation:
options(scipen=999)

#Download data from API (this API is a table queried from Flipside's database: Velocity)
data_Hop <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/a3b95431-4c5b-4ae7-b8d6-88a713cc76bb/data/latest")
data_L2 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/474b623d-f32c-4162-91df-af773cf24cae/data/latest")

data2_Hop <- rawToChar(data_Hop$content)
data2_L2 <- rawToChar(data_L2$content)

data3_Hop <- as_tibble(fromJSON(data2_Hop, flatten = TRUE))
data3_L2 <- as_tibble(fromJSON(data2_L2, flatten = TRUE))

data3_Hop$DATE <- as_date(data3_Hop$DATE)
data3_L2$DATE <- as_date(data3_L2$DATE)

data <- data3_Hop %>% 
  a

to.remove <- ls()
to.remove <- c(to.remove[!grepl("data", to.remove)], "to.remove")
rm(list=to.remove)



#Analysis:

# something like for each bridge 
# - unique users daily 
# - number of transactions daily 
# - avg amount of assets daily



#References:

# https://chainlist.org/
# https://hop.exchange/
# https://github.com/hop-protocol/hop/blob/develop/packages/core/src/addresses/mainnet.ts
# https://flipsidecrypto.xyz/