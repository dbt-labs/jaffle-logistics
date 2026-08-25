
    
    

with all_values as (

    select
        vehicle_type as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_vehicles
    group by vehicle_type

)

select *
from all_values
where value_field not in (
    'van','box_truck','semi'
)


