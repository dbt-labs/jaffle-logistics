
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select note_id
from sthibeault_test_db.dbt_sthibeault.stg_crm_notes
where note_id is null



  
  
      
    ) dbt_internal_test