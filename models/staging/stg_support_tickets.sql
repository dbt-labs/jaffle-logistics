-- One row per support ticket (a threaded conversation lives in body).
select
    ticket_id,
    client_id,
    nullif(shipment_id, '')         as shipment_id,
    cast(opened_at as timestamp)    as opened_at,
    channel,
    status,
    {{ dbt.safe_cast("nullif(cast(csat as " ~ dbt.type_string() ~ "), '')", dbt.type_int()) }} as csat,
    -- body is stored with embedded newlines escaped to '~~NL~~' (portable seed-
    -- loading workaround: some engines reject a quoted CSV field containing a
    -- real newline unless configured otherwise); restore them here.
    replace(body, '~~NL~~', chr(10)) as body
from {{ ref('support_tickets') }}
