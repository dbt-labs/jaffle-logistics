
  create or replace   view sthibeault_test_db.dbt_sthibeault.stg_dispatch_notes
  
  
  
  
  as (
    -- One row per dispatch note.
select
    note_id,
    route_id,
    driver_id,
    hub_id,
    cast(timestamp as timestamp)    as noted_at,
    exception_type,
    body
from sthibeault_test_db.dbt_sthibeault.dispatch_notes
  );

