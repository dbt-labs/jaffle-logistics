
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select chunk_id
from sthibeault_test_db.dbt_sthibeault.transcript_chunks_meta
where chunk_id is null



  
  
      
    ) dbt_internal_test