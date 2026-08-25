-- Hub dimension.
select
    hub_id,
    city,
    hub_function,
    capacity_pkg_day
from {{ ref('stg_hubs') }}
