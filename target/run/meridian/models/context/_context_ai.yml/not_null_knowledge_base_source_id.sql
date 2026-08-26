
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select source_id
from sthibeault_test_db.dbt_sthibeault.knowledge_base
where source_id is null



  
  
      
    ) dbt_internal_test