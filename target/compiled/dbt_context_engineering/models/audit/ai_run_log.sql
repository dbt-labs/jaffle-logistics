

select
    cast(null as TEXT)    as invocation_id,
    cast(null as TEXT)    as model_name,
    cast(null as TEXT)    as function_name,
    cast(null as integer)       as row_count,
    cast(null as numeric(28,6))   as est_tokens,
    cast(null as numeric(28,6))   as est_cost,
    cast(null as timestamp) as run_at,
    cast(null as boolean)   as completed
-- from (select 1) gives the WHERE a FROM (BigQuery forbids WHERE without FROM); 0 rows, typed columns
from (select 1) as _one
where 1 = 0