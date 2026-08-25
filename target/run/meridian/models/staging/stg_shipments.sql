
  create or replace   view sthibeault_test_db.dbt_sthibeault.stg_shipments
  
  
  
  
  as (
    -- One row per shipment. Light typing; blank strings -> null. No joins.
select
    shipment_id,
    client_id,
    origin_hub_id,
    service_level,
    cast(created_at as timestamp)                    as created_at,
    -- cast to varchar first so this works whether dbt seeds delivered_at as a
    -- timestamp (empties -> null) or as a raw string
    try_cast(nullif(cast(delivered_at as varchar), '') as timestamp) as delivered_at,
    status,
    nullif(route_id, '')                             as route_id
from sthibeault_test_db.dbt_sthibeault.shipments
  );

