
    
    

with all_values as (

    select
        sentiment as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_crm_notes
    group by sentiment

)

select *
from all_values
where value_field not in (
    'positive','neutral','concerned'
)


