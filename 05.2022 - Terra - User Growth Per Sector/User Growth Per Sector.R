# --What sectors / Apps are driving user growth on Terra? Are there any sectors / apps that are driving more user growth than others?
# --Choose the top apps per sector (DEXs, Borrowing, Staking, NFTs ...) and create a dashboard of user growth per sector and App. 


library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)

#Download data from API (this API is a table queried from Flipside's database: Velocity)
data <- GET("https://api.flipsidecrypto.com/api/v2/queries/af747a83-b8c7-43db-9390-d43d759acea4/data/latest")

#The code used to query was:
 
# select date(BLOCK_TIMESTAMP) as dates,
# recipient_label_type,
# recipient_label_subtype,
# recipient_label,
# count(distinct sender) as users
# from terra.transfer_events
# where recipient_label_type in ('nft', 'dex', 'layer2', 'cex', 'defi', 'dapp')
# group by dates,
# recipient_label_type,
# recipient_label_subtype,
# recipient_label


#Lets take a look and see which part of this data we need to get:
str(data) #we're going for $content, which is our raw data

#We then need to convert the raw Unicode into a character vector:
data2 <- rawToChar(data$content)

#Finally, we convert the json data of interest into a table:
data3 <- as_tibble(fromJSON(data2, flatten = TRUE))
#we could also us 'flatten = FALSE' if we don't want to automatically flatten nested data frames

data3$DATES <- as_date(data3$DATES)

data3

to.remove <- ls()
to.remove <- c(to.remove[!grepl("data3", to.remove)], "to.remove")
rm(list=to.remove)


#Analysis:

data3 %>% 
  ggplot(aes(x = DATES, y = USERS))+
  geom_line()+
  facet_wrap(~RECIPIENT_LABEL_TYPE) +
  scale_x_date(date_breaks = "6 month", date_labels = "%b-%Y") +
  ggtitle("Label type")



data3 %>% 
  filter(RECIPIENT_LABEL_TYPE != 'dapp') %>% 
  ggplot(aes(x = DATES, y = USERS))+
  geom_line()+
  facet_wrap(~RECIPIENT_LABEL_TYPE) +
  scale_x_date(date_breaks = "6 month", date_labels = "%b-%Y")+
  ggtitle("Label type")



data3 %>% 
  filter(RECIPIENT_LABEL_TYPE == 'dapp') %>% 
  ggplot(aes(x = DATES, y = USERS))+
  geom_line()+
  facet_wrap(~RECIPIENT_LABEL) +
  scale_x_date(date_breaks = "6 month", date_labels = "%b-%Y")+
  ggtitle("Dapps")

data3 %>% 
  filter(RECIPIENT_LABEL_TYPE == 'defi') %>% 
  ggplot(aes(x = DATES, y = USERS))+
  geom_line()+
  facet_wrap(~RECIPIENT_LABEL) +
  scale_x_date(date_breaks = "6 month", date_labels = "%b-%Y")+
  ggtitle("Defi")


data3 %>% 
  filter(RECIPIENT_LABEL_TYPE == 'dex') %>% 
  ggplot(aes(x = DATES, y = USERS))+
  geom_line()+
  facet_wrap(~RECIPIENT_LABEL) +
  scale_x_date(date_breaks = "6 month", date_labels = "%b-%Y")+
  ggtitle("Dex")



data3 %>% 
  filter(RECIPIENT_LABEL_TYPE == 'cex') %>% 
  ggplot(aes(x = DATES, y = USERS))+
  geom_line()+
  facet_wrap(~RECIPIENT_LABEL) +
  scale_x_date(date_breaks = "6 month", date_labels = "%b-%Y")+
  ggtitle("Cex")
