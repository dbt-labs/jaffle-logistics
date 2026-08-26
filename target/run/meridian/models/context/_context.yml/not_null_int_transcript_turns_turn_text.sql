
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select turn_text
from sthibeault_test_db.dbt_sthibeault.int_transcript_turns
where turn_text is null



  
  
      
    ) dbt_internal_test