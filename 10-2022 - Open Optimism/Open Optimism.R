library(tidyverse)
library(shroomDK)

query <- create_query_token(
            query = "SELECT * FROM optimism.core.fact_delegations LIMIT 10",
            api_key = readLines("10-2022 - Open Optimism/api_key.txt"),
            ttl = 15,
            cache = TRUE)

data <- get_query_from_token(query$token, readLines("10-2022 - Open Optimism/api_key.txt"), 1, 10000)

data <- as_tibble(clean_query(data, try_simplify = TRUE))

data
