-- One row per incident. Nullable FK columns: blank strings -> null.
select
    incident_id,
    type                            as incident_type,
    cast(severity as integer)       as severity,
    nullif(shipment_id, '')         as shipment_id,
    nullif(route_id, '')            as route_id,
    nullif(driver_id, '')           as driver_id,
    nullif(vehicle_id, '')          as vehicle_id,
    hub_id,
    cast(occurred_at as timestamp)  as occurred_at,
    summary
from {{ ref('incidents') }}
