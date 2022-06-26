#The code used to query from Flipside's database Velocity was:

1)
#Show the average TPS per second by hour
#Show transaction gas price over time
select date(block_timestamp) as date,
       hour(block_timestamp) as hour,
       count(*)/3600 as TPS,
       avg(gas_price) as avg_gas_price, --> to properly measur it in AVAX this has to be divided by 1000000000
       avg(tx_fee) as avg_tx_fee,
       avg(avax_value) as avg_avax_value
from avalanche.core.fact_transactions
where date > '2022-06-19'
group by date, hour

2)
#What's the average number of transactions per block? 
#What's the max number of transactions we've seen in a block and the minimum?
select avg(tx_count) as avg_tx,
       max(tx_count) as max_tx,
  	   min(tx_count) as min_tx
from avalanche.core.fact_blocks
where date(block_timestamp) > '2022-06-19'

3)
#Show the average time between blocks over time
select date(block_timestamp) as date,
    block_timestamp,
    time(block_timestamp) as time, 
    timediff(second, time(block_timestamp), lag(time(block_timestamp), 1) over (order by block_timestamp))*-1  as difference_in_seconds
from avalanche.core.fact_blocks
where date > '2022-06-19'