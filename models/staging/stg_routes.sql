-- One row per route (one driver-day at one hub).
select
    route_id,
    hub_id,
    driver_id,
    vehicle_id,
    cast(service_date as date)          as service_date,
    cast(stop_count as integer)         as stop_count,
    cast(exceptions_count as integer)   as exceptions_count,
    status
from {{ ref('routes') }}
