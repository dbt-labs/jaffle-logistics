
    
    

select
    vehicle_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_vehicles
where vehicle_id is not null
group by vehicle_id
having count(*) > 1


