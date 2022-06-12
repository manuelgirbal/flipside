#Identify accounts that have staked ETH with Lido when the price of ETH was much higher or much lower than it is now. 
#Have they held or sold their stETH?


library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

#Disabling scientific notation:
options(scipen=999)

#Download data from API (this API is a table queried from Flipside's database: Velocity)
data <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/f9b75a25-85ff-419c-b363-5f5929a4062a/data/latest")

#Lets take a look and see which part of this data we need to get:
str(data) #we're going for $content, which is our raw data

#We then need to convert the raw Unicode into a character vector:
data2 <- rawToChar(data$content)

#Finally, we convert the json data of interest into a table:
data3 <- as_tibble(fromJSON(data2, flatten = TRUE))
#we could also us 'flatten = FALSE' if we don't want to automatically flatten nested data frames

data3$DATE <- as_date(data3$DATE)

data3 <- data3 %>% 
  arrange(DATE) %>% 
  filter(!is.na(USER_ADDRESS))

to.remove <- ls()
to.remove <- c(to.remove[!grepl("data3", to.remove)], "to.remove")
rm(list=to.remove)

#Notes about the dataset:
  # We got a dataset of all addresses that staked ETH someday (more than 1k usd) and still have a stETH balance.
  # We won't see how well did those that sold all their stETH but we can yet see those who still have some stETH related to its present value.


#Analysis:




#References:
  # https://etherscan.io/token/0xae7ab96520de3a18e5e111b5eaab095312d7fe84
  # https://stake.lido.fi/
  # https://flipsidecrypto.xyz/
  # https://coinmarketcap.com/
