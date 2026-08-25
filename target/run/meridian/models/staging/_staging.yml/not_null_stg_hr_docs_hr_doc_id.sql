
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select hr_doc_id
from sthibeault_test_db.dbt_sthibeault.stg_hr_docs
where hr_doc_id is null



  
  
      
    ) dbt_internal_test