
  
    

create or replace transient table sthibeault_test_db.dbt_sthibeault.knowledge_base
    
    
    
    as (-- Phase 4 — one account-scoped knowledge base over every embedded source, in the
-- package's common shape (source_type, source_id, account_key, text, embedding, ts,
-- citation_url). This is what makes "everything about Kellerman across systems" a
-- single vector search. Pure portable SQL (union + common-shape casts); zero AI cost
-- itself, but it reads the embedding models, so build those (Phase 3) first.
--
-- All sources MUST share one embedding model (var embedding_model) — a corpus embedded
-- by one model can't be searched by another (version_guard enforces this upstream).
--
-- source_type here is a COARSE label ('context_chunk' / 'ticket') because the macro
-- stamps it as a literal per source; the FINE-grained artifact type (call_transcript,
-- legal_doc, incident_report, crm_note) is preserved in citation_url
-- (meridian://<fine_type>/<id>) and in source_id (chunk_id encodes the source artifact).


select
    'context_chunk' as source_type,
    cast(chunk_id as TEXT)    as source_id,
    cast(client_id as TEXT)  as account_key,cast(chunk_text as TEXT)         as text,
    embedding as embedding,
    cast(artifact_ts as timestamp)     as ts,
    cast(citation_url as TEXT) as citation_url
from sthibeault_test_db.dbt_sthibeault.chunk_embeddings
union all
select
    'ticket' as source_type,
    cast(ticket_id as TEXT)    as source_id,
    cast(client_id as TEXT)  as account_key,cast(body as TEXT)         as text,
    embedding as embedding,
    cast(opened_at as timestamp)     as ts,
    cast(citation_url as TEXT) as citation_url
from sthibeault_test_db.dbt_sthibeault.ticket_embeddings

    )
;


  