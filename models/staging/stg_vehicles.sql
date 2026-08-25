-- One row per vehicle.
select
    vehicle_id,
    hub_id,
    type                as vehicle_type,
    status,
    cast(odometer as integer) as odometer
from {{ ref('vehicles') }}
