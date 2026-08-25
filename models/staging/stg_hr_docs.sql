-- One row per HR document.
select
    hr_doc_id,
    driver_id,
    doc_type,
    cast(created_at as date)    as created_at,
    author,
    body
from {{ ref('hr_docs') }}
