-- One row per incident report / postmortem.
select
    report_id,
    incident_id,
    author,
    cast(filed_at as timestamp)     as filed_at,
    cast(severity as integer)       as severity,
    nullif(shipment_id, '')         as shipment_id,
    -- body is stored with embedded newlines escaped to '~~NL~~' (portable seed-
    -- loading workaround: some engines reject a quoted CSV field containing a
    -- real newline unless configured otherwise); restore them here.
    replace(body, '~~NL~~', chr(10)) as body
from {{ ref('incident_reports') }}
