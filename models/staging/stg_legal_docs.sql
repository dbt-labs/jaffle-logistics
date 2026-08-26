-- One row per legal document. client_id / driver_id may be blank per doc_type.
select
    doc_id,
    nullif(client_id, '')           as client_id,
    nullif(driver_id, '')           as driver_id,
    cast(effective_date as date)    as effective_date,
    doc_type,
    -- body is stored with embedded newlines escaped to '~~NL~~' (portable seed-
    -- loading workaround: some engines reject a quoted CSV field containing a
    -- real newline unless configured otherwise); restore them here.
    replace(body, '~~NL~~', chr(10)) as body
from {{ ref('legal_docs') }}
