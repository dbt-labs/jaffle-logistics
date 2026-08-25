
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select account_month_key
from sthibeault_test_db.dbt_sthibeault.fct_account_health
where account_month_key is null



  
  
      
    ) dbt_internal_test