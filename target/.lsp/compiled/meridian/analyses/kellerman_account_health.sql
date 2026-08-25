-- The Kellerman decline, straight from the fct_account_health mart: on-time %
-- trending down while ticket and incident counts trend up over 2025.
select
    to_char(month, 'YYYY-MM')    as month,
    shipments,
    ontime_pct,
    sla_target,
    ontime_vs_target,
    ticket_count,
    incident_count,
    health
from sthibeault_test_db.dbt_sthibeault.fct_account_health
where client_id = 'CLI-0042'
order by month