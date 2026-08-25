
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select incident_id
from sthibeault_test_db.dbt_sthibeault.stg_incident_reports
where incident_id is null



  
  
      
    ) dbt_internal_test