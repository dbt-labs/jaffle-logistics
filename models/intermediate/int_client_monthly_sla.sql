-- Monthly on-time performance per client, straight from shipments. This is the
-- statistical backbone the Jaffle Equipment decline rides on and the input to
-- fct_account_health's on-time column. Grain: one row per (client, month).

with shipments as (
    select * from {{ ref('stg_shipments') }}
)

select
    client_id,
    {{ dbt.date_trunc('month', 'created_at') }}                 as month,
    count(*)                                                    as shipments,
    sum(case when status = 'delivered' then 1 else 0 end)       as delivered,
    sum(case when status in ('delayed', 'failed', 'returned')
             then 1 else 0 end)                                 as not_ontime,
    round(100.0 * sum(case when status = 'delivered' then 1 else 0 end)
          / nullif(count(*), 0), 1)                             as ontime_pct
from shipments
group by 1, 2
