
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select vehicle_id
from sthibeault_test_db.dbt_sthibeault.stg_routes
where vehicle_id is null



  
  
      
    ) dbt_internal_test