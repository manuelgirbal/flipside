#The code used to query from Flipside's database Velocity was:

    # with prices as 
    # (
    #   select hour::date as date1,
    #   avg(price) as sol_price
    #   from ethereum.core.fact_hourly_token_prices
    #   where token_address = lower('0xD31a59c85aE9D8edEFeC411D448f90841571b89c')
    #   and date1 >= '2022-04-01'
    #   group by 1
    #   order by 1 desc
    # )
    # ,
    # 
    # transactions as 
    # (
    #   select block_timestamp::date as date2,
    #   count(*) as transactions
    #   from flipside_prod_db.solana.fact_transactions
    #   where date2 >= '2022-04-01'
    #   and succeeded = 'TRUE'
    #   group by 1
    # )
    # ,
    # 
    # stablecoin as
    # (
    #   select block_timestamp::date as date3,
    #   sum(swap_to_amount) as amount_converted,
    #   count(*) as swaps_to_stablecoin
    #   from flipside_prod_db.solana.fact_swaps
    #   where date3 >= '2022-04-01'
    #   and succeeded = 'TRUE'
    #   and (swap_to_mint = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v' --USDC
    #        or swap_to_mint = 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB')--USDT
    #   group by 1  
    # )
    # ,
    # 
    # activity as 
    # (
    #   select block_timestamp::date as date4,
    #   label_type,
    #   label_subtype,
    #   count(*)
    #   from flipside_prod_db.solana.fact_transfers
    #   left join flipside_prod_db.solana.dim_labels
    #   on flipside_prod_db.solana.fact_transfers.tx_to = flipside_prod_db.solana.dim_labels.address
    #   where date4 >= '2022-04-01'
    #   group by 1, 2, 3
    # )
    # 
    # select *
    #   from prices
    # left join transactions
    # on prices.date1 = transactions.date2
    # left join stablecoin
    # on prices.date1 = stablecoin.date3
    # left join activity
    # on prices.date1 = activity.date4