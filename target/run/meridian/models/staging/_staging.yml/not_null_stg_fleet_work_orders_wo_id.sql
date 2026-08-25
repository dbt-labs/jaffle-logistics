
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select wo_id
from sthibeault_test_db.dbt_sthibeault.stg_fleet_work_orders
where wo_id is null



  
  
      
    ) dbt_internal_test