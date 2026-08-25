
    
    

select
    incident_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.fct_incidents
where incident_id is not null
group by incident_id
having count(*) > 1


