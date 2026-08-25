
    
    

with all_values as (

    select
        doc_type as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_hr_docs
    group by doc_type

)

select *
from all_values
where value_field not in (
    'onboarding','disciplinary','training'
)


