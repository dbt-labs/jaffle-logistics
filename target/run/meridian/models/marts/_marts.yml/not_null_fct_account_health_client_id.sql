
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select client_id
from sthibeault_test_db.dbt_sthibeault.fct_account_health
where client_id is null



  
  
      
    ) dbt_internal_test