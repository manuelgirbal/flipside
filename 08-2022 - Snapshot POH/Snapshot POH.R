# https://docs.flipsidecrypto.com/shroomdk-sdk/sdks/r

library(devtools)
devtools::install_github(repo = 'FlipsideCrypto/sdk', subdir = 'r/shroomDK')
library(shroomDK)
library(tidyverse)

query <- create_query_token(
          query = "select * from ethereum.core.ez_snapshot where space_id = 'poh.eth' or space_id = 'proofofhumanity.eth'",
          api_key = readLines("08-2022 - Snapshot POH/api_key.txt"),
          ttl = 15,
          cache = TRUE)

data <- get_query_from_token(query_token = query$token, 
                     api_key = readLines("08-2022 - Snapshot POH/api_key.txt"),
                     1,
                     10000)

data_final <- as_tibble(clean_query(data, try_simplify = FALSE))

data_final
