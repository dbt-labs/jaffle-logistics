
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select client_id
from sthibeault_test_db.dbt_sthibeault.int_client_monthly_sla
where client_id is null



  
  
      
    ) dbt_internal_test