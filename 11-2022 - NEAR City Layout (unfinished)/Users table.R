# Table docs at https://docs.metricsdao.xyz/data-curation/data-curation/near/table-documentation


library(tidyverse)
library(shroomDK)

query <- create_query_token(
  query = "SELECT * FROM near.core.fact_transactions", # ver cómo acortar: estamos buscando una medida de actividad/existencia/frecuencia y una de balances
  api_key = readLines("11-2022 - NEAR City Layout/api_key.txt"),
  ttl = 15,
  cache = TRUE)

near_users <- get_query_from_token(query$token, readLines("11-2022 - NEAR City Layout/api_key.txt"), 1, 10000)

near_users <- as_tibble(clean_query(near_users, try_simplify = TRUE))


# Podemos usar "near.core.metrics_active_wallets" como medida de usuarios activos
# Considerar: "near.core.metrics_daily_transactions", "near.core.fact_transactions", "near.core.fact_actions_events"
# Tener en cuenta dificultades recientes que hubo para calcular la distribución de $NEAR por address: https://app.flipsidecrypto.com/dashboard/near-distribution-zdDv8V


