
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select doc_key
from sthibeault_test_db.dbt_sthibeault.int_context_documents
where doc_key is null



  
  
      
    ) dbt_internal_test