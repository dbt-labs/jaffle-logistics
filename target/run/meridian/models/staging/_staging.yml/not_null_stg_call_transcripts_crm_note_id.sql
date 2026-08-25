
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select crm_note_id
from sthibeault_test_db.dbt_sthibeault.stg_call_transcripts
where crm_note_id is null



  
  
      
    ) dbt_internal_test