library(httr)
library(jsonlite)
library(tidyverse)

#Download data from API (this API is a table queried from Flipsides database: Velocity)
test <- GET("https://api.flipsidecrypto.com/api/v2/queries/ddc05329-2885-464a-ae3a-d6433fd528da/data/latest")

#Lets take a look and see which part of this data we need to get:
str(test) #we're going for $content, which appears to be raw data

#We then need to convert the raw Unicode into a character vector:
test2 <- rawToChar(test$content)

#Finally, we convert the json data of interest into a table:
test3 <- fromJSON(test2, flatten = TRUE)
#we could also us 'flatten = FALSE' if we don't want to automatically flatten nested data frames