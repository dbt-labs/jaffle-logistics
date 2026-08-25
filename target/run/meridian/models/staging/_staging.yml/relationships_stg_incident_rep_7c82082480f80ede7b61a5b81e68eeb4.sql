
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select incident_id as from_field
    from sthibeault_test_db.dbt_sthibeault.stg_incident_reports
    where incident_id is not null
),

parent as (
    select incident_id as to_field
    from sthibeault_test_db.dbt_sthibeault.stg_incidents
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test