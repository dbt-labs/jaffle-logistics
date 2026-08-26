-- Phase 3 — governed incremental embedding of whole tickets (REAL Cortex cost). DO
-- NOT run until spend is approved. Same governed pattern as chunk_embeddings; tickets
-- are short enough to embed whole, so the unit is the ticket body (no chunking).





with embedded as (
    select
        ticket_id,
        client_id,
        opened_at,
        body,
        citation_url,
        content_hash,
        ai_embed('snowflake-arctic-embed-m-v1.5', body) as embedding
    from sthibeault_test_db.dbt_sthibeault.stg_tickets_hashed
    
)

select
    ticket_id,
    client_id,
    opened_at,
    body,
    citation_url,
    content_hash,
    'snowflake-arctic-embed-m-v1.5'                                 as model_version,
    embedding,
    array_size(embedding) as embedding_dimension,
    '3217651b87d8be851e8e9c62583061b9'                                            as embedding_fn_fingerprint,
    '2026-08-25 19:47:21.666469+00:00'                                         as embedded_at,
    '93a0765f23e8758e6de88c722bfd3e4069738f6ce0a04a49e8aaa8a819b48327'        as embedding_logic_hash
from embedded