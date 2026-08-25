-- STATISTICAL query (the "haystack"): weather delays by month across 2025.
-- Aggregates weather-typed incidents and weather-tagged dispatch exceptions
-- alongside total delayed shipments, so the Jan-Feb and Nov-Dec winter/peak
-- spikes emerge from the broad layer. Run: dbt compile then execute, or paste
-- into a DuckDB session against meridian.duckdb.

with weather_incidents as (
    select date_trunc('month', occurred_at) as month, count(*) as weather_incidents
    from {{ ref('stg_incidents') }}
    where incident_type = 'weather'
    group by 1
),
weather_dispatch as (
    select date_trunc('month', noted_at) as month, count(*) as weather_dispatch_notes
    from {{ ref('stg_dispatch_notes') }}
    where exception_type = 'weather'
    group by 1
),
delayed as (
    select date_trunc('month', created_at) as month, count(*) as delayed_shipments
    from {{ ref('stg_shipments') }}
    where status = 'delayed'
    group by 1
)
select
    {{ month_key('d.month') }}                      as month,
    coalesce(wi.weather_incidents, 0)               as weather_incidents,
    coalesce(wd.weather_dispatch_notes, 0)          as weather_dispatch_notes,
    d.delayed_shipments
from delayed d
left join weather_incidents wi on wi.month = d.month
left join weather_dispatch wd  on wd.month = d.month
order by d.month
