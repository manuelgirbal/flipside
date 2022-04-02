library(httr)
library(jsonlite )

#Download data from API (this API is a table queried from Flipsides database: Velocity)
test <- GET("https://api.flipsidecrypto.com/api/v2/queries/0980f35f-8585-491b-aa26-49aed8570426/data/latest")

#Lets take a look and see which part of this data we need to get:
str(test) #we're going for $content, which appears to be raw data

#We then need to convert the raw Unicode into a character vector:
test2 <- rawToChar(test$content)

#Finally, we conver the json data of interest into a table:
test3 <- fromJSON(test2, flatten = TRUE)
test4 <- fromJSON(test2, flatten = FALSE)