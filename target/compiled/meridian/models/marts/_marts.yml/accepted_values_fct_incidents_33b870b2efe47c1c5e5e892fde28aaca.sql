
    
    

with all_values as (

    select
        incident_type as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.fct_incidents
    group by incident_type

)

select *
from all_values
where value_field not in (
    'damage','delay','accident','mispick','dispute','weather'
)


