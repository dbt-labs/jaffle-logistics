
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select driver_id
from sthibeault_test_db.dbt_sthibeault.dim_drivers
where driver_id is null



  
  
      
    ) dbt_internal_test