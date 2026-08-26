-- One row per HR document.
select
    hr_doc_id,
    driver_id,
    doc_type,
    cast(created_at as date)    as created_at,
    author,
    -- body is stored with embedded newlines escaped to '~~NL~~' (portable seed-
    -- loading workaround: some engines reject a quoted CSV field containing a
    -- real newline unless configured otherwise); restore them here.
    replace(body, '~~NL~~', chr(10)) as body
from {{ ref('hr_docs') }}
