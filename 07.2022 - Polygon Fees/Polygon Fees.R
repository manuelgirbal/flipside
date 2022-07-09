library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

options(scipen=999)

data_1 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/cab5b462-052f-4409-97ab-10e63ab320f9/data/latest")

data_2 <- rawToChar(data_1$content)

data_3 <- as_tibble(fromJSON(data_2, flatten = TRUE))

data_3$MATIC_DATE_HOUR <- as.POSIXct(data_3$MATIC_DATE_HOUR)



#ETH and BTC daily price (from https://coinmarketcap.com/):
maticprice <- read.csv("07.2022 - Polygon Fees/matic-usd-max.csv")
ethprice <- read.csv("07.2022 - Polygon Fees/eth-usd-max.csv")

maticprice <- as_tibble(maticprice) %>%
  mutate(DATES = as_date(snapped_at)) %>% 
  group_by(DATES) %>% 
  mutate(maticprice = round(mean(price),4)) %>% 
  filter(DATES >= '2022-07-01') %>% 
  select(DATES, maticprice)

ethprice <- as_tibble(ethprice) %>%
  mutate(DATES = as_date(snapped_at)) %>% 
  group_by(DATES) %>% 
  mutate(ethprice = round(mean(price),4)) %>% 
  filter(DATES >= '2022-07-01') %>% 
  select(DATES, ethprice)            


#Merging tables:
data_3$DATES <- as_date(data_3$MATIC_DATE_HOUR)

finaldata <- data_3 %>%
  left_join(maticprice, by = "DATES") %>% 
  left_join(ethprice, by = "DATES") %>% 
  mutate(matic_usd_fee = AVG_FEE_MATIC*maticprice,
         eth_usd_fee = AVG_FEE_ETH*ethprice)

to.remove <- ls()
to.remove <- c(to.remove[!grepl("finaldata", to.remove)], "to.remove")
rm(list=to.remove)


##Analysis:


--Visualize transaction fees on Polygon since July 1, 2022.
--Compare these to fees on Ethereum over the same time period - are they correlated? Do they diverge significantly at any points? Provide analysis as to why you think this might be.
--We will be giving the top 15 submissions a 125 $USDC payout, with the best getting the grand prize of 2,000 $USDC and 2nd place taking 1,000 $USDC

--Comparison between transaction fees, we compare fees in USD value measured in today exchange rate

--this table contains transaction level data for the polygon blockchain. 
--each transaction will have a unique transaction hash, along with transactions fees and a matic/eth value transferred when applicable. 
--transactions may be native matic/eth transfers or interactions with contract addresses. 

--ver si sumo un agrupamiento intermedio por tipo de transacción o la data que contiene
--En R convertir las fees a USD bajando data de coinmarketcap