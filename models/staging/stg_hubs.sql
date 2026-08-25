-- One row per hub. Light typing/renaming, no joins.
select
    hub_id,
    city,
    function            as hub_function,
    cast(capacity_pkg_day as integer) as capacity_pkg_day
from {{ ref('hubs') }}
