-- content_hash home for tickets (see stg_chunks_hashed). Tickets are short, so they
-- are embedded WHOLE (no chunking) — the ticket body is the embedding unit. A
-- synthetic citation_url points back to the ticket. Zero AI cost.
{{ config(materialized='view') }}

select
    ticket_id,
    client_id,
    opened_at,
    body,
    'meridian://support_ticket/' || ticket_id                as citation_url,
    {{ dbt_context_engineering.content_hash('body') }}       as content_hash
from {{ ref('stg_support_tickets') }}
where body is not null
  and length(trim(body)) > 0
