#Using the Ethereum_core schema, analyze inflows and outflows to RocketPool over the past three months. 
#As we near the ETH 2 merge, are there any emerging trends? 
#What is the average deposit size and how has that changed vs. historical performance?

library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)

#Download data from API (this API is a table queried from Flipside's database: Velocity)
data <- GET("https://api.flipsidecrypto.com/api/v2/queries/52ba56ce-eaab-4b72-b3e3-3f0673851a1a/data/latest")

#The code used to query was:
# with a as 
# (
#   select date(block_timestamp) as adates,
#   tx_hash as atxhash,
#   event_name
#   from ethereum_core.fact_event_logs
#   where contract_address = '0xae78736cd615f374d3085123a210448e74fc6393' -- rETH contract (RocketPool)
#   and (event_name = 'TokensBurned' or event_name = 'TokensMinted')
# )
# ,
# 
# b as 
# (
#   select date(block_timestamp) as bdates,
#   tx_hash as btxhash,
#   symbol,
#   token_price,
#   amount,
#   amount_usd,
#   from_address,
#   to_address
#   from ethereum_core.ez_token_transfers
#   where symbol = 'rETH'
# )
# 
# select adates as dates,
# atxhash as tx_hash,
# event_name,
# symbol,
# round(token_price,0) as token_price,
# round(amount,0) as amount,
# round(amount_usd,0) as amount_usd,
# case when dates > CURRENT_DATE()-90 then 'last3months'
# else 'historical'
# end as period,
# from_address,
# to_address
# from a
# left join b
# on a.atxhash = b.btxhash


#Lets take a look and see which part of this data we need to get:
str(data) #we're going for $content, which is our raw data

#We then need to convert the raw Unicode into a character vector:
data2 <- rawToChar(data$content)

#Finally, we convert the json data of interest into a table:
data3 <- as_tibble(fromJSON(data2, flatten = TRUE))
#we could also us 'flatten = FALSE' if we don't want to automatically flatten nested data frames

data3[is.na(data3)] = 0
data3$DATES <- as_date(data3$DATES)

data3

to.remove <- ls()
to.remove <- c(to.remove[!grepl("data3", to.remove)], "to.remove")
rm(list=to.remove)

#PARA ANALIZAR:
#calcular el tamaño de depósito (en USD) diario y agregado por período (last3months vs histórico):

data3 %>%
  group_by(EVENT_NAME, DATES) %>% 
  summarise(averageUSD = mean(AMOUNT_USD)) %>% 
  select(EVENT_NAME, DATES, averageUSD) %>% 
  ggplot(aes(DATES, averageUSD)) +
  geom_line(aes(colour = EVENT_NAME)) +
  geom_vline(xintercept = as.numeric(as.Date("2022-01-25")))
#falta mejorar la estética del gráfico


today()

#calcular el tamaño en cantidad de transacciones (usos que se le da al protocolo e interés en staking):
data3 %>%
  group_by(EVENT_NAME, DATES) %>% 
  summarise(n = n()) %>% 
  select(EVENT_NAME, DATES, n) %>% 
  ggplot(aes(DATES, n)) +
  geom_line(aes(colour = EVENT_NAME)) +
  geom_vline(xintercept = as.numeric(as.Date("2022-01-25")))


#ver si podemos calcular período de stake (viendo address de envío y destino)



