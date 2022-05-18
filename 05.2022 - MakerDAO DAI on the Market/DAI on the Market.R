#Analyze large shifts in the amount of DAI on the market over the past year. What might have caused these shifts? 
#Are these events related to Maker directly? Are they related to the crypto ecosystem as a whole? 
#Provide metrics to support your analysis.

library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)

#Disabling scientific notation:
options(scipen=999)

#Download data from API (this API is a table queried from Flipside's database: Velocity)
data <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/4949a932-a735-4f3b-bf4c-5bb2959b1121/data/latest")

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


#ETH and BTC daily price (from https://coinmarketcap.com/):
btcprice <- read.csv("05.2022 - MakerDAO DAI on the Market/btc-usd-max.csv")
ethprice <- read.csv("05.2022 - MakerDAO DAI on the Market/eth-usd-max.csv")

btcprice <- as_tibble(btcprice) %>%
  mutate(DATES = as_date(snapped_at)) %>% 
  group_by(DATES) %>% 
  mutate(btcprice = round(mean(price),0)) %>% 
  select(DATES, btcprice)

ethprice <- as_tibble(ethprice) %>%
  mutate(DATES = as_date(snapped_at)) %>% 
  group_by(DATES) %>% 
  mutate(ethprice = round(mean(price),0)) %>% 
  select(DATES, ethprice)            


#Merging tables (baseline: first day of the last year period):
data <- data3 %>% 
  group_by(DATES) %>% 
  summarise(DAIVOL = sum(DAIVOLUME)) %>% 
  left_join(btcprice, by = "DATES") %>% 
  left_join(ethprice, by = "DATES")


#Data with variation:
data_variation <- data %>%
  arrange(DATES) %>% 
  mutate(DAI_VOL_VAR = round((DAIVOL/lag(DAIVOL)-1)*100,1),
         BTC_VAR = round((btcprice /lag(btcprice )-1)*100,1),
         ETH_VAR = round((ethprice /lag(ethprice )-1)*100,1))

data_variation[is.na(data_variation)] <- 0




#Analysis:
data_variation %>% 
  ggplot(aes(DATES, DAIVOL)) +
  geom_line()


plot(data_variation$DATES,data_variation$BTC_VAR, type="l",col="red",
     xlab="date", ylab="% daily variation")
lines(data_variation$DATES,data_variation$ETH_VAR,col="blue")


cor(data_variation$BTC_VAR, data_variation$ETH_VAR)
cor(data_variation$BTC_VAR, data_variation$DAI_VOL_VAR)
cor(data_variation$DAI_VOL_VAR, data_variation$ETH_VAR)

