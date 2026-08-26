
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select source_type
from sthibeault_test_db.dbt_sthibeault.chunks_with_meta
where source_type is null



  
  
      
    ) dbt_internal_test