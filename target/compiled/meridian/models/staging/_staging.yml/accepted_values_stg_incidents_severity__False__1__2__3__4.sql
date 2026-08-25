
    
    

with all_values as (

    select
        severity as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_incidents
    group by severity

)

select *
from all_values
where value_field not in (
    1,2,3,4
)


