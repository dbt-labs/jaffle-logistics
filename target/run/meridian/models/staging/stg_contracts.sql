
  create or replace   view sthibeault_test_db.dbt_sthibeault.stg_contracts
  
  
  
  
  as (
    -- One row per contract.
select
    contract_id,
    client_id,
    cast(effective_date as date)    as effective_date,
    cast(sla_ontime_pct as double)  as sla_ontime_pct,
    credit_terms
from sthibeault_test_db.dbt_sthibeault.contracts
  );

