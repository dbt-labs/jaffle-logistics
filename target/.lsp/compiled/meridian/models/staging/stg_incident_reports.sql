-- One row per incident report / postmortem.
select
    report_id,
    incident_id,
    author,
    cast(filed_at as timestamp)     as filed_at,
    cast(severity as integer)       as severity,
    nullif(shipment_id, '')         as shipment_id,
    body
from sthibeault_test_db.dbt_sthibeault.incident_reports