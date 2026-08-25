-- One row per dispatch note.
select
    note_id,
    route_id,
    driver_id,
    hub_id,
    cast(timestamp as timestamp)    as noted_at,
    exception_type,
    body
from {{ ref('dispatch_notes') }}
