
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select hub_id
from sthibeault_test_db.dbt_sthibeault.dim_hubs
where hub_id is null



  
  
      
    ) dbt_internal_test