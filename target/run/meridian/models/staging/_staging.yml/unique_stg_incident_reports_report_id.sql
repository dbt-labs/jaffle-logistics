
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    report_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_incident_reports
where report_id is not null
group by report_id
having count(*) > 1



  
  
      
    ) dbt_internal_test