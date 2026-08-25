
    
    

with all_values as (

    select
        channel as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_support_tickets
    group by channel

)

select *
from all_values
where value_field not in (
    'email','phone','chat','portal'
)


