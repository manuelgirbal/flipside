#The code used to query from Flipside's database Velocity was:

1)

    # with tokens as 
    # ( 
    #   select date(block_timestamp) as date,
    #   symbol,
    #   case 
    #   when (to_address = lower('0x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf') 
    #         or to_address = lower('0xa0c68c638235ee32657e8f720a23cec1bfc77c77')) then 'polygon'
    #   when  to_address = lower('0x99c9fc46f92e8a1c0dec1b1747d010903e884be1') then 'optimism'
    #   else 'arbitrum'	
    #   end as L2,
    #   count(origin_from_address) as user_addresses,
    #   sum(amount) as amount,
    #   sum(amount_usd) as amount_usd
    #   from ethereum.core.ez_token_transfers
    #   where (to_address = lower('0x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf') --Polygon
    #          or to_address = lower('0xa0c68c638235ee32657e8f720a23cec1bfc77c77') --Polygon
    #          or to_address = lower('0x99c9fc46f92e8a1c0dec1b1747d010903e884be1') --Optimism
    #          or to_address = lower('0x4dbd4fc535ac27206064b68ffcf827b0a60bab3f')) --Arbitrum
    #   and date >= '2022-01-01'
    #   and (symbol = 'DAI' or symbol = 'USDT' or symbol = 'USDC' or symbol = 'MATIC')
    #   and amount_usd is not null
    #   group by date, symbol, L2
    # )
    # ,
    # 
    # eth as 
    # (
    #   select date(block_timestamp) as date,
    #   'ETH' as symbol,
    #   case 
    #   when (eth_to_address = lower('0x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf') 
    #         or eth_to_address = lower('0xa0c68c638235ee32657e8f720a23cec1bfc77c77')) then 'polygon'
    #   when  eth_to_address = lower('0x99c9fc46f92e8a1c0dec1b1747d010903e884be1') then 'optimism'
    #   else 'arbitrum'	
    #   end as L2,
    #   count(origin_from_address) as user_addresses,
    #   sum(amount) as amount,
    #   sum(amount_usd) as amount_usd
    #   from ethereum.core.ez_eth_transfers
    #   where (eth_to_address = lower('0x40ec5b33f54e0e8a33a975908c5ba1c14e5bbbdf') --Polygon
    #          or eth_to_address = lower('0xa0c68c638235ee32657e8f720a23cec1bfc77c77') --Polygon
    #          or eth_to_address = lower('0x99c9fc46f92e8a1c0dec1b1747d010903e884be1') --Optimism
    #          or eth_to_address = lower('0x4dbd4fc535ac27206064b68ffcf827b0a60bab3f')) --Arbitrum
    #   and date >= '2022-01-01'
    #   and amount_usd is not null
    #   group by date, L2  
    # )
    # 
    # select * from tokens
    # union all 
    # select * from eth

2)

    # with tokens as 
    # (
    #   select date(tt.block_timestamp) as date,
    #   tt.symbol,
    #   el.event_inputs:chainId as recipient_chainId,
    #   count(tt.origin_from_address) as user_addresses,
    #   sum(tt.amount) as amount,
    #   sum(tt.amount_usd) as amount_usd
    #   from ethereum.core.ez_token_transfers as tt
    #   left join ethereum.core.fact_event_logs as el
    #   on tt.tx_hash = el.tx_hash
    #   where (tt.to_address = lower('0x3E4a3a4796d16c0Cd582C382691998f7c06420B6') --USDT
    #          or tt.to_address = lower('0x22B1Cbb8D98a01a3B71D034BB899775A76Eb1cc2') --MATIC
    #          or tt.to_address = lower('0x3d4Cc8A61c7528Fd86C55cfe061a78dCBA48EDd1') --DAI
    #          or tt.to_address = lower('0x3666f603Cc164936C1b87e207F36BEBa4AC5f18a')) --USDC
    #   and date >= '2022-01-01'
    #   and amount_usd is not null
    #   and (recipient_chainId = '10' or recipient_chainId = '42161' or recipient_chainId = '137')
    #   group by date, symbol, recipient_chainId  
    # )
    # ,
    # 
    # eth as 
    # (
    #   select date(et.block_timestamp) as date,
    #   'ETH' as symbol,
    #   el.event_inputs:chainId as recipient_chainId,
    #   count(et.origin_from_address) as user_addresses,
    #   sum(et.amount) as amount,
    #   sum(et.amount_usd) as amount_usd
    #   from ethereum.core.ez_eth_transfers as et
    #   left join ethereum.core.fact_event_logs as el
    #   on et.tx_hash = el.tx_hash
    #   where eth_to_address = lower('0xb8901acB165ed027E32754E0FFe830802919727f') --ETH
    #   and date >= '2022-01-01'
    #   and amount_usd is not null
    #   and (recipient_chainId = '10' or recipient_chainId = '42161' or recipient_chainId = '137')
    #   group by date, recipient_chainId  
    # )
    # 
    # select * from tokens
    # union all 
    # select * from eth