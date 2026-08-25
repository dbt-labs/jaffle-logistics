
    
    

with all_values as (

    select
        note_type as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_crm_notes
    group by note_type

)

select *
from all_values
where value_field not in (
    'QBR','call','plan'
)


