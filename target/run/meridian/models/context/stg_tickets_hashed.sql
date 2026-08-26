
  create or replace   view sthibeault_test_db.dbt_sthibeault.stg_tickets_hashed
  
  
  
  
  as (
    -- content_hash home for tickets (see stg_chunks_hashed). Tickets are short, so they
-- are embedded WHOLE (no chunking) — the ticket body is the embedding unit. A
-- synthetic citation_url points back to the ticket. Zero AI cost.


select
    ticket_id,
    client_id,
    opened_at,
    body,
    'meridian://support_ticket/' || ticket_id                as citation_url,
    sha2(body, 256)       as content_hash
from sthibeault_test_db.dbt_sthibeault.stg_support_tickets
where body is not null
  and length(trim(body)) > 0
  );

