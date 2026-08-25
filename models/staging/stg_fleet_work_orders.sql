-- One row per fleet work order. linked_incident_id blank -> null.
select
    wo_id,
    vehicle_id,
    hub_id,
    cast(opened_at as timestamp)        as opened_at,
    nullif(linked_incident_id, '')      as linked_incident_id,
    cast(cost as integer)               as cost,
    body
from {{ ref('fleet_work_orders') }}
