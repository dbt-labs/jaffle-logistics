-- Incident fact (grain: one row per incident), enriched with hub city and flags
-- for whether an incident report and/or a fleet work order were filed against it.
with incidents as (
    select * from sthibeault_test_db.dbt_sthibeault.stg_incidents
),
hubs as (
    select hub_id, city from sthibeault_test_db.dbt_sthibeault.stg_hubs
),
reports as (
    select incident_id, count(*) as report_count
    from sthibeault_test_db.dbt_sthibeault.stg_incident_reports
    group by 1
),
work_orders as (
    select linked_incident_id as incident_id, count(*) as work_order_count
    from sthibeault_test_db.dbt_sthibeault.stg_fleet_work_orders
    where linked_incident_id is not null
    group by 1
)
select
    i.incident_id,
    i.incident_type,
    i.severity,
    i.hub_id,
    h.city              as hub_city,
    i.shipment_id,
    i.route_id,
    i.driver_id,
    i.vehicle_id,
    i.occurred_at,
    date_trunc('month', i.occurred_at)          as occurred_month,
    coalesce(r.report_count, 0)                 as report_count,
    coalesce(w.work_order_count, 0)             as work_order_count,
    (coalesce(r.report_count, 0) > 0)           as has_report,
    i.summary
from incidents i
left join hubs h        on h.hub_id = i.hub_id
left join reports r     on r.incident_id = i.incident_id
left join work_orders w on w.incident_id = i.incident_id