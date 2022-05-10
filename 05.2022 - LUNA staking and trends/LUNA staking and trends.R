

library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(scales)
library(plotly)

#Download data from API (this API is a table queried from Flipside's database: Velocity)
data <- GET("https://api.flipsidecrypto.com/api/v2/queries/728f6c73-fbbe-4656-a66b-18c45a2a8058/data/latest")

#The code used to query was:
# with table1 as (
#   select date(date) as dates,
#   balance_type,
#   round(sum(balance),2) as totalLUNA
#   from   terra.daily_balances
#   where  currency = 'LUNA'
#   and  address_label is null
#   and dates > '2020-12-31'
#   group by balance_type, dates
# )
# ,
# 
# table2 as (
#   select *
#     from table1
#   pivot (sum(totalLUNA) for balance_type in ('liquid', 'staked'))
#   as p (dates, liquid, staked)
# )
# 
# select *,
# staked/(liquid+staked)*100 as staked_over_circulating
# from table2



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


#Analysis:
data3 %>% 
  filter(DATES < "2022-04-30") %>% 
  ggplot(aes(DATES)) +
  geom_line(aes(y = STAKED, colour = "Staked"), size=1) + 
  geom_line(aes(y = LIQUID, colour = "Liquid"), size=1) +
  theme_minimal() +
  scale_x_date(date_breaks = "1 month", date_labels = "%b-%Y") +
  scale_y_continuous(name = "LUNA Circulating Supply", labels = comma) +
  ggtitle("Staked & Liquid LUNA over time")



data3 %>% 
  filter(DATES < "2022-04-30") %>% 
  ggplot(aes(DATES, STAKED_OVER_CIRCULATING)) +
  geom_line(size=1, color = "darkblue") + 
  theme_minimal() +
  scale_x_date(date_breaks = "1 month", date_labels = "%b-%Y") +
  scale_y_continuous(name = "% of LUNA Staked", labels = comma, limits = c(40,80)) +
  ggtitle("LUNA staked as % of total circulating supply")



#TEST:

plot_ly(data3, x = ~DATES, y = ~STAKED, type = 'scatter', mode = 'lines')

