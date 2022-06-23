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

data3_Hop <- data3_Hop %>% 
  mutate(BRIDGE = 'Hop',
         L2 = case_when(
           RECIPIENT_CHAINID == '137' ~ "polygon",
           RECIPIENT_CHAINID == '42161' ~ "arbitrum",
           TRUE ~ "optimism"
         )) %>% 
  select(DATE, SYMBOL, L2, USER_ADDRESSES, TRANSACTIONS, AVG_AMOUNT_USD, BRIDGE)

data3_L2 <- data3_L2 %>% 
  mutate(BRIDGE = 'Native')

data4 <- data3_Hop %>% 
  union_all(data3_L2)

to.remove <- ls()
to.remove <- c(to.remove[!grepl("data4", to.remove)], "to.remove")
rm(list=to.remove)


#Analysis:

# Unique users daily:
data4 %>%
  filter(SYMBOL == 'ETH',
         L2 == 'polygon') %>% 
  ggplot(aes(DATE, USER_ADDRESSES, color = BRIDGE)) +
  geom_line(size=1) +
  scale_x_date(date_breaks = "1 month", date_minor_breaks = "1 week", date_labels = "%b-%Y") +
  xlab("") +
  ylab("")

# Number of daily transactions:
data4 %>%
  filter(SYMBOL == 'ETH',
         L2 == 'polygon') %>% 
  ggplot(aes(DATE, TRANSACTIONS, color = BRIDGE)) +
  geom_line(size=1) +
  scale_x_date(date_breaks = "1 month", date_minor_breaks = "1 week", date_labels = "%b-%Y") +
  xlab("") +
  ylab("")

# Avg amount of assets daily:
data4 %>%
  filter(SYMBOL == 'ETH',
         L2 == 'polygon') %>% 
  ggplot(aes(DATE, AVG_AMOUNT_USD, color = BRIDGE)) +
  geom_line(size=1) +
  scale_x_date(date_breaks = "1 month", date_minor_breaks = "1 week", date_labels = "%b-%Y") +
  xlab("") +
  ylab("")
