#The code used to query from Flipside's database Velocity was:

    # with staking as 
    # (
    #   select origin_from_address,
    #   date(block_timestamp) as date,
    #   token_price,
    #   amount,
    #   amount_usd
    #   from ethereum.core.ez_token_transfers
    #   where contract_address = lower('0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84')
    #   and amount > 1000
    # )
    # ,
    # 
    # balances as 
    # (
    #   select user_address,
    #   symbol,
    #   price,
    #   decimals,
    #   non_adjusted_balance,
    #   balance,
    #   amount_usd as amount_usd2
    #   from flipside_prod_db.ethereum.erc20_balances
    #   where contract_address = lower('0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84')
    #   and balance_date = CURRENT_DATE - 1  
    # )
    # 
    # select *
    #   from staking
    # left join balances
    # on staking.origin_from_address = balances.user_address