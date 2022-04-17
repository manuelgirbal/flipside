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
      # avg(voting_power) as mean_voting_power_YES --revisar si es LUNA llano o si hay que sacarle algunos decimales
      # from terra.gov_vote
      # where option = 'VOTE_OPTION_YES'
      # group by proposal_id, validator_vs_regular

#Lets take a look and see which part of this data we need to get:
str(data) #we're going for $content, which is our raw data

#We then need to convert the raw Unicode into a character vector:
data2 <- rawToChar(data$content)

#Finally, we convert the json data of interest into a table:
data3 <- fromJSON(data2, flatten = TRUE)
#we could also us this 'flatten = FALSE' if we don't want to automatically flatten nested data frames

data3 <- as_tibble(
  data3 %>% 
  mutate(ID = as.factor(ID))
  )

data3

#Este gráfico está interesante pero acortaría el rango de la variable para mayor claridad:
data3 %>% 
  ggplot(aes(x = ID, y = MEAN_VOTING_POWER_YES)) +
  geom_point(aes(color = VALIDATOR_VS_REGULAR))

#idem
data3 %>% 
  ggplot(aes(x = ID, y = N)) +
  geom_point(aes(color = VALIDATOR_VS_REGULAR))

