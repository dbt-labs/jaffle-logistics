
    
    

with all_values as (

    select
        employment_type as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_drivers
    group by employment_type

)

select *
from all_values
where value_field not in (
    'employee','contractor'
)


