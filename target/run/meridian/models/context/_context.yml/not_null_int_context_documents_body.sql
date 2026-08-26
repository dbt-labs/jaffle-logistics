
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select body
from sthibeault_test_db.dbt_sthibeault.int_context_documents
where body is null



  
  
      
    ) dbt_internal_test