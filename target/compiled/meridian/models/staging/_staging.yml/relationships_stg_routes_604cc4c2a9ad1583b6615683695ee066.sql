
    
    

with child as (
    select vehicle_id as from_field
    from sthibeault_test_db.dbt_sthibeault.stg_routes
    where vehicle_id is not null
),

parent as (
    select vehicle_id as to_field
    from sthibeault_test_db.dbt_sthibeault.stg_vehicles
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


