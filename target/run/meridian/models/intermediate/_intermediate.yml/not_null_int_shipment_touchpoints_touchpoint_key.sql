
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select touchpoint_key
from sthibeault_test_db.dbt_sthibeault.int_shipment_touchpoints
where touchpoint_key is null



  
  
      
    ) dbt_internal_test