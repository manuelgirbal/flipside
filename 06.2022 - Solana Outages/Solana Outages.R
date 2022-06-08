#Solana experienced another outage on 6/1 where validators were forced to restart the network. 
#The network experienced a similar problem back on 5/1. 
#After the restart happens during these outages, how do users on the network generally respond?
#Does the price of SOL drop because users lose confidence in the network? Is there more swapping behavior and more stablecoin activity? 
#What protocols seem to have more activity after these types of events that on the average day in the Solana ecosystem? 
#Is there more fear from defi Solana users than NFT enjoyers?

library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

#Disabling scientific notation:
options(scipen=999)

#Download data from API (this API is a table queried from Flipside's database: Velocity)
data <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/17b75965-83c6-4994-89f4-002dc05326bb/data/latest")

#Lets take a look and see which part of this data we need to get:
str(data) #we're going for $content, which is our raw data

#We then need to convert the raw Unicode into a character vector:
data2 <- rawToChar(data$content)

#Finally, we convert the json data of interest into a table:
data3 <- as_tibble(fromJSON(data2, flatten = TRUE))
#we could also us 'flatten = FALSE' if we don't want to automatically flatten nested data frames

data3$DATE1 <- as_date(data3$DATE1)

to.remove <- ls()
to.remove <- c(to.remove[!grepl("data3", to.remove)], "to.remove")
rm(list=to.remove)


#Separate dataframes:
price <- data3 %>% 
  group_by(DATE1) %>% 
  summarize(price = mean(SOL_PRICE))

transactions <- data3 %>% 
  group_by(DATE1) %>% 
  summarize(transactions = mean(TRANSACTIONS))

stablecoin <- data3 %>% 
  group_by(DATE1) %>% 
  summarize(amount = mean(AMOUNT_CONVERTED),
            swaps = mean(SWAPS_TO_STABLECOIN))

stablecoin <- data3 %>% 
  group_by(DATE1) %>% 
  summarize(amount = mean(AMOUNT_CONVERTED),
            swaps = mean(SWAPS_TO_STABLECOIN))


cex_dex <- data3 %>% 
  group_by(DATE1) %>%
  filter(LABEL_TYPE  %in% c('dex', 'cex')) %>% 
  summarize(transactions = mean(`COUNT(*)`))

nft <- data3 %>% 
  group_by(DATE1) %>%
  filter(LABEL_TYPE  == 'nft') %>% 
  summarize(transactions = mean(`COUNT(*)`))  


#Analysis:
price %>%
  ggplot(aes(DATE1, price)) +
  geom_line(size=1) +
  geom_vline(xintercept = as.numeric(as.Date("2022-05-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-04-30"), label="Outage1", y=75), colour="blue", angle=90) +
  geom_vline(xintercept = as.numeric(as.Date("2022-06-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-05-31"), label="Outage2", y=75), colour="red", angle=90) +
  scale_x_date(date_breaks = "1 week", date_minor_breaks = "1 week", date_labels = "%d-%b-%Y") +
  xlab("dates") +
  ylab("SOL price")


transactions %>%
  ggplot(aes(DATE1, transactions)) +
  geom_line(size=1) +
  geom_vline(xintercept = as.numeric(as.Date("2022-05-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-04-30"), label="Outage1", y=20000000), colour="blue", angle=90) +
  geom_vline(xintercept = as.numeric(as.Date("2022-06-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-05-31"), label="Outage2", y=20000000), colour="red", angle=90) +
  scale_x_date(date_breaks = "1 week", date_minor_breaks = "1 week", date_labels = "%d-%b-%Y") +
  xlab("dates") +
  ylab("transactions")


stablecoin %>%
  ggplot(aes(DATE1, amount)) +
  geom_line(size=1) +
  geom_vline(xintercept = as.numeric(as.Date("2022-05-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-04-30"), label="Outage1", y=150000000), colour="blue", angle=90) +
  geom_vline(xintercept = as.numeric(as.Date("2022-06-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-05-31"), label="Outage2", y=150000000), colour="red", angle=90) +
  scale_x_date(date_breaks = "1 week", date_minor_breaks = "1 week", date_labels = "%d-%b-%Y") +
  xlab("dates") +
  ylab("USD amount converted to stablecoin")

stablecoin %>%
  ggplot(aes(DATE1, swaps)) +
  geom_line(size=1) +
  geom_vline(xintercept = as.numeric(as.Date("2022-05-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-04-30"), label="Outage1", y=160000), colour="blue", angle=90) +
  geom_vline(xintercept = as.numeric(as.Date("2022-06-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-05-31"), label="Outage2", y=160000), colour="red", angle=90) +
  scale_x_date(date_breaks = "1 week", date_minor_breaks = "1 week", date_labels = "%d-%b-%Y") +
  xlab("dates") +
  ylab("amount of swaps to stablecoin")



cex_dex %>%
  ggplot(aes(DATE1, transactions)) +
  geom_line(size=1) +
  geom_vline(xintercept = as.numeric(as.Date("2022-05-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-04-30"), label="Outage1", y=25000), colour="blue", angle=90) +
  geom_vline(xintercept = as.numeric(as.Date("2022-06-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-05-31"), label="Outage2", y=25000), colour="red", angle=90) +
  scale_x_date(date_breaks = "1 week", date_minor_breaks = "1 week", date_labels = "%d-%b-%Y") +
  xlab("dates") +
  ylab("transactions to cex/dex")


nft %>%
  ggplot(aes(DATE1, transactions)) +
  geom_line(size=1) +
  geom_vline(xintercept = as.numeric(as.Date("2022-05-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-04-30"), label="Outage1", y=100), colour="blue", angle=90) +
  geom_vline(xintercept = as.numeric(as.Date("2022-06-01")), linetype="dashed", size=1) +
  geom_text(aes(x= as.Date("2022-05-31"), label="Outage2", y=100), colour="red", angle=90) +
  scale_x_date(date_breaks = "1 week", date_minor_breaks = "1 week", date_labels = "%d-%b-%Y") +
  xlab("dates") +
  ylab("transactions to nft")
