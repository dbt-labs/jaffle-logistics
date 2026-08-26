-- Monthly account-health fact (grain: one row per client-month). Surfaces the
-- Jaffle Equipment (CLI-0042) decline: on-time % trending down while ticket and
-- incident counts trend up across the year. Joins the monthly SLA backbone to
-- monthly ticket and incident counts, and carries the client's current health
-- flag and contract SLA target for context.

with sla as (
    select * from {{ ref('int_client_monthly_sla') }}
),
clients as (
    select client_id, client_name, tier, health, sla_ontime_pct
    from {{ ref('dim_clients') }}
),
tickets as (
    select
        client_id,
        date_trunc('month', opened_at)  as month,
        count(*)                        as ticket_count
    from {{ ref('stg_support_tickets') }}
    group by 1, 2
),
-- incidents attributed to a client via the shipment they reference
incidents as (
    select
        s.client_id,
        date_trunc('month', i.occurred_at)  as month,
        count(*)                            as incident_count
    from {{ ref('stg_incidents') }} i
    join {{ ref('stg_shipments') }} s on s.shipment_id = i.shipment_id
    where i.shipment_id is not null
    group by 1, 2
)
select
    sla.client_id || ':' || {{ month_key('sla.month') }}    as account_month_key,
    sla.client_id,
    c.client_name,
    c.tier,
    c.health,
    c.sla_ontime_pct                                        as sla_target,
    sla.month,
    sla.shipments,
    sla.ontime_pct,
    round(sla.ontime_pct - c.sla_ontime_pct, 1)            as ontime_vs_target,
    coalesce(t.ticket_count, 0)                             as ticket_count,
    coalesce(inc.incident_count, 0)                         as incident_count
from sla
left join clients c   on c.client_id = sla.client_id
left join tickets t   on t.client_id = sla.client_id and t.month = sla.month
left join incidents inc on inc.client_id = sla.client_id and inc.month = sla.month
order by sla.client_id, sla.month
