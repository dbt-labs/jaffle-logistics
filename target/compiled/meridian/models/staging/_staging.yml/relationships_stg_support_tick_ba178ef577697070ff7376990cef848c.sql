
    
    

with child as (
    select shipment_id as from_field
    from sthibeault_test_db.dbt_sthibeault.stg_support_tickets
    where shipment_id is not null
),

parent as (
    select shipment_id as to_field
    from sthibeault_test_db.dbt_sthibeault.stg_shipments
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


