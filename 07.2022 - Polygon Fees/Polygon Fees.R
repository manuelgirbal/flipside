library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
library(plotly)

options(scipen=999)

data_1 <- GET("https://node-api.flipsidecrypto.com/api/v2/queries/cab5b462-052f-4409-97ab-10e63ab320f9/data/latest")

data_2 <- rawToChar(data_1$content)

data_3 <- as_tibble(fromJSON(data_2, flatten = TRUE))

data_3$MATIC_DATE_HOUR <- as_datetime(data_3$MATIC_DATE_HOUR)


maticprice <- read.csv("07.2022 - Polygon Fees/matic-usd-max.csv")
ethprice <- read.csv("07.2022 - Polygon Fees/eth-usd-max.csv")

maticprice <- as_tibble(maticprice) %>%
  mutate(DATES = as_date(snapped_at)) %>% 
  group_by(DATES) %>% 
  mutate(maticprice = round(mean(price),4)) %>% 
  filter(DATES >= '2022-07-01') %>% 
  select(DATES, maticprice)

ethprice <- as_tibble(ethprice) %>%
  mutate(DATES = as_date(snapped_at)) %>% 
  group_by(DATES) %>% 
  mutate(ethprice = round(mean(price),4)) %>% 
  filter(DATES >= '2022-07-01') %>% 
  select(DATES, ethprice)            


#Merging tables:
data_3$DATES <- as_date(data_3$MATIC_DATE_HOUR)

finaldata <- data_3 %>%
  left_join(maticprice, by = "DATES") %>% 
  left_join(ethprice, by = "DATES") %>% 
  mutate(MATIC_USD_FEE = AVG_FEE_MATIC*maticprice,
         ETH_USD_FEE = AVG_FEE_ETH*ethprice) %>% 
  select(DATE_HOUR = MATIC_DATE_HOUR,
         MATIC_TRANSACTIONS,
         AVG_FEE_MATIC,
         MATIC_USD_FEE,
         ETH_TRANSACTIONS,
         AVG_FEE_ETH,
         ETH_USD_FEE
  )

to.remove <- ls()
to.remove <- c(to.remove[!grepl("finaldata", to.remove)], "to.remove")
rm(list=to.remove)


##Analysis:



#Fees comparison:
finaldata %>%
  ggplot(aes(DATE_HOUR)) +
  geom_line(aes(y=MATIC_USD_FEE), size=1, color = "#D55E00") +
  geom_line(aes(y=ETH_USD_FEE), size=1, color = "#00AFBB") +
  theme_minimal() +
  labs(title = "Polygon vs Ethereum transaction fees (in USD vaue)",
       y="USD value",
       x="Date")

cor.test(finaldata$MATIC_USD_FEE, finaldata$ETH_USD_FEE, method = "pearson")


#Amount of transactions comparison:
finaldata %>%
  ggplot(aes(DATE_HOUR)) +
  geom_line(aes(y=MATIC_TRANSACTIONS), size=1, color = "#D55E00") +
  geom_line(aes(y=ETH_TRANSACTIONS), size=1, color = "#00AFBB") +
  theme_minimal() +
  labs(title = "Polygon vs Ethereum transactions",
       y="Transactions",
       x="Date")

cor.test(finaldata$MATIC_TRANSACTIONS, finaldata$ETH_TRANSACTIONS, method = "pearson")


#Comparison between fees and amount of transactions on same blockchain:
cor.test(finaldata$MATIC_TRANSACTIONS, finaldata$MATIC_USD_FEE, method = "pearson")

cor.test(finaldata$ETH_TRANSACTIONS, finaldata$ETH_USD_FEE, method = "pearson")


