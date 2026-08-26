-- The Jaffle Equipment decline, straight from the fct_account_health mart: on-time %
-- trending down while ticket and incident counts trend up over 2025.
select
    {{ month_key('month') }}    as month,
    shipments,
    ontime_pct,
    sla_target,
    ontime_vs_target,
    ticket_count,
    incident_count,
    health
from {{ ref('fct_account_health') }}
where client_id = 'CLI-0042'
order by month
