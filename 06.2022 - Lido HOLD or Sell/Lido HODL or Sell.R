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
  mutate_if(is.numeric, round, digits=2)

data3$BALANCE[is.na(data3$BALANCE)] <- 0 
data3$AMOUNT_USD2[is.na(data3$AMOUNT_USD2)] <- 0 

to.remove <- ls()
to.remove <- c(to.remove[!grepl("data3", to.remove)], "to.remove")
rm(list=to.remove)

data4 <- data3 %>% 
  group_by(ORIGIN_FROM_ADDRESS) %>% 
  summarize(amount_stETHinvested = sum(AMOUNT),
            amount_USDinvested = sum(AMOUNT_USD),
            amount_stETHheld = sum(BALANCE),
            amount_USDheld = sum(AMOUNT_USD2)) %>% 
  mutate(type = case_when(
           (amount_stETHinvested <= amount_stETHheld) == TRUE ~ "HODL", #HODL or got more from secondary markets, but not less
           (amount_USDheld == "0") == TRUE ~ "SOLD",
           TRUE ~ "sold_some"),
         current_balance = (amount_USDheld - amount_USDinvested))

HODL <- data4 %>% 
  filter(type == "HODL",
         current_balance < 500000000) #excluding some outliers
#For those who account more than they staked (aquired from secondary markets) we don't really know how much they invested


sold_some <- data4 %>% 
  filter(type == "sold_some")

SOLD <- data4 %>% 
  filter(type == "SOLD")


##Analysis:
data4

#Summary:
data4 %>% 
  group_by(type) %>% 
  summarize(n = n())

#Hodlers:

plot_ly(x = ~HODL$current_balance, 
        type = "histogram") %>% 
        layout(bargap=0.1,
               xaxis = list(title = 'Current USD Balance'))

