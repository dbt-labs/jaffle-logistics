-- Shipment fact (grain: one row per shipment), enriched with client/hub context,
-- an on-time flag, and a count of stitched touchpoints across all artifact types.
with shipments as (
    select * from {{ ref('stg_shipments') }}
),
clients as (
    select client_id, client_name, tier, line_of_business from {{ ref('stg_clients') }}
),
hubs as (
    select hub_id, city from {{ ref('stg_hubs') }}
),
touchpoints as (
    select shipment_id, count(*) as touchpoint_count
    from {{ ref('int_shipment_touchpoints') }}
    group by 1
)
select
    s.shipment_id,
    s.client_id,
    cl.client_name,
    cl.tier             as client_tier,
    s.origin_hub_id,
    h.city              as origin_city,
    s.service_level,
    s.status,
    (s.status = 'delivered')                        as is_ontime,
    s.created_at,
    s.delivered_at,
    {{ dbt.date_trunc('month', 's.created_at') }}    as created_month,
    s.route_id,
    coalesce(t.touchpoint_count, 0)                 as touchpoint_count
from shipments s
left join clients cl on cl.client_id = s.client_id
left join hubs h     on h.hub_id = s.origin_hub_id
left join touchpoints t on t.shipment_id = s.shipment_id
