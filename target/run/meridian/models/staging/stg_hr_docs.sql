
  create or replace   view sthibeault_test_db.dbt_sthibeault.stg_hr_docs
  
  
  
  
  as (
    -- One row per HR document.
select
    hr_doc_id,
    driver_id,
    doc_type,
    cast(created_at as date)    as created_at,
    author,
    body
from sthibeault_test_db.dbt_sthibeault.hr_docs
  );

