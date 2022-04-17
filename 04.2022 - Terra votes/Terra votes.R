#On average, how much voting power (in Luna) was used to vote 'YES' for governance proposals?
#Out of this, how much Luna comes from validators vs regular wallets?

library(httr)
library(jsonlite)
library(tidyverse)

#Download data from API (this API is a table queried from Flipsides database: Velocity)
data <- GET("https://api.flipsidecrypto.com/api/v2/queries/ddc05329-2885-464a-ae3a-d6433fd528da/data/latest")

#The code used to query was:
      # select proposal_id::number as id,
      # case
      # when voter in (select address from terra.labels where label_subtype = 'validator') then 'validator'
      # else 'regular'
      # end as validator_vs_regular,
      # count(voter) as n,   
      # avg(voting_power) as mean_voting_power_YES
      # from terra.gov_vote
      # where option = 'VOTE_OPTION_YES'
      # group by proposal_id, validator_vs_regular

#Lets take a look and see which part of this data we need to get:
str(data) #we're going for $content, which is our raw data

#We then need to convert the raw Unicode into a character vector:
data2 <- rawToChar(data$content)

#Finally, we convert the json data of interest into a table:
data3 <- fromJSON(data2, flatten = TRUE)
#we could also us 'flatten = FALSE' if we don't want to automatically flatten nested data frames

data3 <- as_tibble(
  data3 %>% 
  mutate(ID = as.factor(ID))
  )

data3

#Plotting mean LUNA voting power per proposal ID:
data3 %>% 
  ggplot(aes(x = ID, y = MEAN_VOTING_POWER_YES)) +
  geom_point(aes(color = VALIDATOR_VS_REGULAR)) +
  scale_y_continuous(labels = scales::comma, limits = c(0, 600000)) +
  theme(legend.position="bottom",
        axis.text.x = element_text(size=7))

#Plotting number of wallets/voters per proposal ID:
data3 %>% 
  ggplot(aes(x = ID, y = N)) +
  geom_point(aes(color = VALIDATOR_VS_REGULAR)) +
  scale_y_continuous(labels = scales::comma, limits = c(0, 4000)) +
  theme(legend.position="bottom",
        axis.text.x = element_text(size=7))
