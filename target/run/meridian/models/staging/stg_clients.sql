
  create or replace   view sthibeault_test_db.dbt_sthibeault.stg_clients
  
  
  
  
  as (
    -- One row per client.
select
    client_id,
    name                as client_name,
    tier,
    line_of_business,
    region,
    health
from sthibeault_test_db.dbt_sthibeault.clients
  );

