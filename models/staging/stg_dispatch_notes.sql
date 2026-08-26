-- One row per dispatch note.
select
    note_id,
    route_id,
    driver_id,
    hub_id,
    cast(timestamp as timestamp)    as noted_at,
    exception_type,
    -- body is stored with embedded newlines escaped to '~~NL~~' (portable seed-
    -- loading workaround: some engines reject a quoted CSV field containing a
    -- real newline unless configured otherwise); restore them here.
    replace(body, '~~NL~~', chr(10)) as body
from {{ ref('dispatch_notes') }}
