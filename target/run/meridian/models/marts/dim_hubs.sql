
  
    

create or replace transient table sthibeault_test_db.dbt_sthibeault.dim_hubs
    
    
    
    as (-- Hub dimension.
select
    hub_id,
    city,
    hub_function,
    capacity_pkg_day
from sthibeault_test_db.dbt_sthibeault.stg_hubs
    )
;


  