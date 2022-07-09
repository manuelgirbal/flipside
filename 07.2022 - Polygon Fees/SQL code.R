#The code used to query from Flipside's database Velocity was:

  with matic as (
    select (date(block_timestamp) ||' '|| hour(block_timestamp))::timestamp as matic_date_hour,
           count(*) as matic_transactions,
           avg(tx_fee) as avg_fee_matic
    from polygon.core.fact_transactions
    where date(block_timestamp) >= '2022-07-01'
    group by matic_date_hour
  )
  ,

  eth as (
    select (date(block_timestamp) ||' '|| hour(block_timestamp))::timestamp as eth_date_hour,
           count(*) as eth_transactions,
           avg(tx_fee) as avg_fee_eth
    from ethereum.core.fact_transactions
    where date(block_timestamp) >= '2022-07-01'
    group by eth_date_hour
  )

  select *
  from matic
  left join eth
  on matic.matic_date_hour = eth.eth_date_hour

