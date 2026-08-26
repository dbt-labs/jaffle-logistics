-- One row per CRM note (QBR / call / plan).
select
    note_id,
    client_id,
    account_owner,
    cast(call_date as date)     as call_date,
    note_type,
    sentiment,
    nullif(shipment_id, '')     as shipment_id,
    -- body is stored with embedded newlines escaped to '~~NL~~' (portable seed-
    -- loading workaround: some engines reject a quoted CSV field containing a
    -- real newline unless configured otherwise); restore them here.
    replace(body, '~~NL~~', chr(10)) as body
from {{ ref('crm_notes') }}
