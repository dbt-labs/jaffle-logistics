
    
    

select
    hub_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.dim_hubs
where hub_id is not null
group by hub_id
having count(*) > 1


