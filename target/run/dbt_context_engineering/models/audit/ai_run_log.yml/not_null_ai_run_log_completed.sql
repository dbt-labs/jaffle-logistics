
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select completed
from sthibeault_test_db.dbt_sthibeault.ai_run_log
where completed is null



  
  
      
    ) dbt_internal_test