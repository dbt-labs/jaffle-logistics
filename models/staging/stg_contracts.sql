-- One row per contract.
select
    contract_id,
    client_id,
    cast(effective_date as date)    as effective_date,
    cast(sla_ontime_pct as {{ dbt.type_float() }})  as sla_ontime_pct,
    credit_terms
from {{ ref('contracts') }}
