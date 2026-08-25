
    
    

with all_values as (

    select
        tier as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_clients
    group by tier

)

select *
from all_values
where value_field not in (
    'strategic','mid','small'
)


