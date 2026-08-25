
  create or replace   view sthibeault_test_db.dbt_sthibeault.stg_vehicles
  
  
  
  
  as (
    -- One row per vehicle.
select
    vehicle_id,
    hub_id,
    type                as vehicle_type,
    status,
    cast(odometer as integer) as odometer
from sthibeault_test_db.dbt_sthibeault.vehicles
  );

