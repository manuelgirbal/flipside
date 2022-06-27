library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

options(scipen=999)

data_1 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/898b643f-c654-4e0c-8007-2a07aaadc4de/data/latest")
data_2 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/2bc0867d-d760-49d6-8c35-b5f4fd2c6dd4/data/latest")
data_3 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/bc15220d-d653-4025-8003-c98dd281f111/data/latest")

data2_1 <- rawToChar(data_1$content)
data2_2 <- rawToChar(data_2$content)
data2_3 <- rawToChar(data_3$content)

data3_1 <- as_tibble(fromJSON(data2_1, flatten = TRUE))
data3_2 <- as_tibble(fromJSON(data2_2, flatten = TRUE))
data3_3 <- as_tibble(fromJSON(data2_3, flatten = TRUE))

data3_1$DATE <- as_date(data3_1$DATE)
data3_3$DATE <- as_date(data3_3$DATE)

data3_1 <- data3_1 %>% 
  mutate(DATE_HOUR = as.POSIXct(paste(data3_1$DATE, data3_1$HOUR), format="%Y-%m-%d %H"))

data3_3 <- data3_3 %>% 
  mutate(DATE_HOUR = as.POSIXct(paste(data3_3$DATE, data3_3$HOUR), format="%Y-%m-%d %H"))


##Analysis:

#Show the average TPS per second by hour:

data3_1 %>% 
  ggplot(aes(DATE_HOUR, TPS)) +
  geom_line(size=1, color = "steelblue") +
  scale_x_datetime(date_breaks = "1 day", date_minor_breaks = "1 hour", date_labels = "%d-%b")


#Show transaction gas price over time

data3_1 %>% 
  ggplot(aes(DATE_HOUR, AVG_GAS_PRICE)) +
  geom_line(size=1, color = "#00AFBB") +
  scale_x_datetime(date_breaks = "1 day", date_minor_breaks = "1 hour", date_labels = "%d-%b")


#What's the average number of transactions per block? 
#What's the max number of transactions we've seen in a block and the minimum?

# valueBox(value, subtitle, icon = NULL, color = "aqua", width = 4,
#          href = NULL)


#Show the average time between blocks over time
data3_3 %>% 
  ggplot(aes(DATE_HOUR, AVG_DIFFERENCE_IN_SECONDS)) +
  geom_line(size=1, color = "#009E73") +
  scale_x_datetime(date_breaks = "1 day", date_minor_breaks = "1 hour", date_labels = "%d-%b")


# Note any other interesting findings about the number of transactions, blocks, or gas for the Avalanche blockchain
data3_1 %>% 
  ggplot(aes(DATE_HOUR, AVG_TX_FEE)) +
  geom_line(size=1, color = "#D55E00") +
  scale_x_datetime(date_breaks = "1 day", date_minor_breaks = "1 hour", date_labels = "%d-%b")

data3_1 %>% 
  ggplot(aes(DATE_HOUR, AVG_AVAX_VALUE)) +
  geom_line(size=1, color = "#E69F00") +
  scale_x_datetime(date_breaks = "1 day", date_minor_breaks = "1 hour", date_labels = "%d-%b")

