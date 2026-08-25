-- Client dimension, enriched with the client's contract SLA target.
with clients as (
    select * from sthibeault_test_db.dbt_sthibeault.stg_clients
),
contracts as (
    select client_id, contract_id, sla_ontime_pct, effective_date
    from sthibeault_test_db.dbt_sthibeault.stg_contracts
)
select
    c.client_id,
    c.client_name,
    c.tier,
    c.line_of_business,
    c.region,
    c.health,
    con.contract_id,
    con.sla_ontime_pct,
    con.effective_date  as contract_effective_date
from clients c
left join contracts con on con.client_id = c.client_id