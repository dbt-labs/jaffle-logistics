
    
    

with all_values as (

    select
        source_type as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.chunks_with_meta
    group by source_type

)

select *
from all_values
where value_field not in (
    'call_transcript','legal_doc','incident_report','crm_note'
)


