-- Legal docs reshaped for their own chunk pipeline: adds a synthetic
-- citation_url (not present on stg_legal_docs) so attach_metadata can carry
-- it downstream. Deliberately its own model, not unioned with the other
-- document sources: each source runs its own chunk -> hash -> classify ->
-- embed path end to end, reflecting that in a real system these would
-- arrive via different systems on different schedules.
{{ config(materialized='view') }}

select
    doc_id,
    client_id,
    body,
    cast(effective_date as {{ dbt.type_timestamp() }}) as artifact_ts,
    'jaffle_logistics://legal_doc/' || doc_id           as citation_url
from {{ ref('stg_legal_docs') }}
