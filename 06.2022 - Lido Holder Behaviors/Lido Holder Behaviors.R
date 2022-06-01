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

#The code used to query was:
  # with hodlers as 
  # (
  #   select top 10 user_address,
  #   round(avg(balance),2) as LDO
  #   from flipside_prod_db.ethereum.erc20_balances
  #   where symbol = 'LDO' 
  #   and balance_date > CURRENT_DATE - 30 
  #   and balance is not null
  #   group by user_address 
  #   order by LDO desc
  # )
  # ,
  # 
  # labeled_hodlers as 
  # (
  #   select user_address,
  #   LDO,
  #   label_type,
  #   label_subtype,
  #   label
  #   from hodlers
  #   left join flipside_prod_db.ethereum_core.dim_labels
  #   on hodlers.user_address = flipside_prod_db.ethereum_core.dim_labels.address
  # )
  # ,
  # 
  # labeled_recipients as 
  # (
  #   select date(block_timestamp) as date,
  #   from_address,
  #   amount,
  #   label_type as recipient_label_type,
  #   label_subtype as recipient_label_subtype,
  #   label as recipient_label
  #   from flipside_prod_db.ethereum_core.ez_token_transfers
  #   left join flipside_prod_db.ethereum_core.dim_labels
  #   on flipside_prod_db.ethereum_core.ez_token_transfers.to_address = flipside_prod_db.ethereum_core.dim_labels.address
  #   where symbol = 'LDO'
  # )
  # 
  # select *
  #   from labeled_hodlers
  # left outer join labeled_recipients
  # on labeled_hodlers.user_address = labeled_recipients.from_address



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


#References:
#   https://flipsidecrypto.xyz/
#   https://stake.lido.fi/
#   https://etherscan.io/token/0x5a98fcbea516cf06857215779fd812ca3bef1b32