-- content_hash home for tickets: needs to be a real column upstream of the
-- embed() call, not a same-SELECT alias. Tickets are short, so they are
-- embedded WHOLE (no chunking), the ticket body is the embedding unit. A
-- synthetic citation_url points back to the ticket. Zero AI-function cost
-- (still ordinary cloud compute cost on Snowflake/BigQuery/Databricks, free
-- only on local DuckDB).
{{ config(materialized='view') }}

select
    ticket_id,
    client_id,
    opened_at,
    body,
    'jaffle_logistics://support_ticket/' || ticket_id         as citation_url,
    {{ dbt_context_engineering.content_hash('body') }}       as content_hash
from {{ ref('stg_support_tickets') }}
where body is not null
  and length(trim(body)) > 0
