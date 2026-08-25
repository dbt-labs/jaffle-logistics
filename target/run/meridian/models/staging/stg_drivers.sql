
  create or replace   view sthibeault_test_db.dbt_sthibeault.stg_drivers
  
  
  
  
  as (
    -- One row per driver.
select
    driver_id,
    hub_id,
    employment_type,
    cast(hire_date as date)   as hire_date,
    status,
    cast(perf_score as double) as perf_score
from sthibeault_test_db.dbt_sthibeault.drivers
  );

