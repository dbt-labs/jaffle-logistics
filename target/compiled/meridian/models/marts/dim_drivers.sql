-- Driver dimension, enriched with home-hub city.
with drivers as (
    select * from sthibeault_test_db.dbt_sthibeault.stg_drivers
),
hubs as (
    select hub_id, city from sthibeault_test_db.dbt_sthibeault.stg_hubs
)
select
    d.driver_id,
    d.hub_id            as home_hub_id,
    h.city             as home_hub_city,
    d.employment_type,
    d.hire_date,
    d.status,
    d.perf_score
from drivers d
left join hubs h on h.hub_id = d.hub_id