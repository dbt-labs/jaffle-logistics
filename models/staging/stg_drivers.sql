-- One row per driver.
select
    driver_id,
    hub_id,
    employment_type,
    cast(hire_date as date)   as hire_date,
    status,
    cast(perf_score as {{ dbt.type_float() }}) as perf_score
from {{ ref('drivers') }}
