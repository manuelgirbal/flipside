# Q2. Explore the behavior of top 5 LDO holders. Include:
#   -LDO balances and history
#   -Typical actions with LDO

library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

#Disabling scientific notation:
options(scipen=999)

#Download data from API (this API is a table queried from Flipside's database: Velocity)
data <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/dab8099e-ef74-44df-be87-6483ba07fe32/data/latest")

#Lets take a look and see which part of this data we need to get:
str(data) #we're going for $content, which is our raw data

#We then need to convert the raw Unicode into a character vector:
data2 <- rawToChar(data$content)

#Finally, we convert the json data of interest into a table:
data3 <- as_tibble(fromJSON(data2, flatten = TRUE))
#we could also us 'flatten = FALSE' if we don't want to automatically flatten nested data frames

data3$DATE <- as_date(data3$DATE)

# Obtained Top 10 hodlers with transactions (balance from May 2022 month average), just LDO on Ethereum (not Solana, etc.)

# Getting top 5 (excluding Treasury)
top5 <- as_vector(
  data3 %>%
  filter(!LABEL_SUBTYPE %in% 'treasury') %>%
  distinct(USER_ADDRESS, LDO) %>%
  arrange(desc(LDO)) %>%
  head(5) %>%
  select(USER_ADDRESS)
  )

data4 <- data3 %>% 
  filter(USER_ADDRESS %in% top5)

# data4$USER_ADDRESS <- abbreviate(data4$USER_ADDRESS, use.classes = FALSE, minlength = 10, strict = TRUE, named = TRUE)
# data4

to.remove <- ls()
to.remove <- c(to.remove[!grepl("data4", to.remove)], "to.remove")
rm(list=to.remove)


#Analysis:
# LDO balances 
balances <- data4 %>% distinct(USER_ADDRESS, LDO)

plot_ly(balances, x = ~USER_ADDRESS, y = ~LDO, type = 'bar') %>%
  layout(title = "",
         yaxis = list(title = "May 2022 LDO Balance" ,
                      zeroline = FALSE),
         xaxis = list(tickangle = 25))
        )

#History
history <- data4 %>%
  select(USER_ADDRESS, FIRST_DATE = DATE) %>% 
  group_by(USER_ADDRESS) %>% 
  arrange(FIRST_DATE) %>%
  slice(1L)
  

# Typical actions with LDO
actions <- data4 %>%
  group_by(USER_ADDRESS) %>%
  summarise(transactions = n(),
         amount = sum(AMOUNT))
