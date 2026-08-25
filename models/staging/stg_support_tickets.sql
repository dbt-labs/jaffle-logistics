-- One row per support ticket (a threaded conversation lives in body).
select
    ticket_id,
    client_id,
    nullif(shipment_id, '')         as shipment_id,
    cast(opened_at as timestamp)    as opened_at,
    channel,
    status,
    try_cast(nullif(cast(csat as varchar), '') as integer) as csat,
    body
from {{ ref('support_tickets') }}
