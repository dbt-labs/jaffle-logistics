-- Incident reports reshaped for their own chunk pipeline: adds a synthetic
-- citation_url and resolves client_id via the affected shipment (incident
-- reports carry no client_id column directly). A report with no shipment_id
-- stays client_id = null (still searchable, just not account-scoped).
-- Deliberately its own model, not unioned with the other document sources:
-- each source runs its own chunk -> hash -> classify -> embed path end to
-- end, reflecting that in a real system these would arrive via different
-- systems on different schedules.
{{ config(materialized='view') }}

select
    r.report_id,
    s.client_id,
    r.body,
    cast(r.filed_at as {{ dbt.type_timestamp() }})           as artifact_ts,
    'jaffle_logistics://incident_report/' || r.report_id     as citation_url
from {{ ref('stg_incident_reports') }} r
left join {{ ref('stg_shipments') }} s
    on r.shipment_id = s.shipment_id
