-- One row per CRM note (QBR / call / plan).
select
    note_id,
    client_id,
    account_owner,
    cast(call_date as date)     as call_date,
    note_type,
    sentiment,
    nullif(shipment_id, '')     as shipment_id,
    body
from sthibeault_test_db.dbt_sthibeault.crm_notes