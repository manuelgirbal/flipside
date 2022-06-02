#The code used to query from Flipside's database Velocity was:
  # with hodlers as 
  # (
  #   select top 10 user_address,
  #   round(avg(balance),2) as LDO
  #   from flipside_prod_db.ethereum.erc20_balances
  #   where symbol = 'LDO' 
  #   and balance_date > CURRENT_DATE - 30 
  #   and balance is not null
  #   group by user_address 
  #   order by LDO desc
  # )
  # ,
  # 
  # labeled_hodlers as 
  # (
  #   select user_address,
  #   LDO,
  #   label_type,
  #   label_subtype,
  #   label
  #   from hodlers
  #   left join flipside_prod_db.ethereum_core.dim_labels
  #   on hodlers.user_address = flipside_prod_db.ethereum_core.dim_labels.address
  # )
  # ,
  # 
  # labeled_recipients as 
  # (
  #   select date(block_timestamp) as date,
  #   from_address,
  #   amount,
  #   label_type as recipient_label_type,
  #   label_subtype as recipient_label_subtype,
  #   label as recipient_label
  #   from flipside_prod_db.ethereum_core.ez_token_transfers
  #   left join flipside_prod_db.ethereum_core.dim_labels
  #   on flipside_prod_db.ethereum_core.ez_token_transfers.to_address = flipside_prod_db.ethereum_core.dim_labels.address
  #   where symbol = 'LDO'
  # )
  # 
  # select *
  #   from labeled_hodlers
  # left outer join labeled_recipients
  # on labeled_hodlers.user_address = labeled_recipients.from_address