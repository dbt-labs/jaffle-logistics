
    
    

with all_values as (

    select
        source as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.int_shipment_touchpoints
    group by source

)

select *
from all_values
where value_field not in (
    'support_ticket','incident','crm_note','incident_report','call_transcript','dispatch_note'
)


