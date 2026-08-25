
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    incident_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_incidents
where incident_id is not null
group by incident_id
having count(*) > 1



  
  
      
    ) dbt_internal_test