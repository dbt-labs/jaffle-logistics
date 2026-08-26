-- Phase 4: one account-scoped knowledge base over every embedded source, in the
-- package's common shape (source_type, source_id, account_key, text, embedding, ts,
-- citation_url). This is what makes "everything about Jaffle Equipment across systems"
-- a single vector search. Pure portable SQL (union + common-shape casts); zero
-- AI-function cost itself, but it reads the embedding models, so build those
-- (Phase 3) first.
--
-- All sources MUST share one embedding model (var embedding_model): a corpus embedded
-- by one model can't be searched by another (version_guard enforces this upstream).
--
-- source_type here is a COARSE label ('context_chunk' / 'ticket') because the macro
-- stamps it as a literal per source; the FINE-grained artifact type (call_transcript,
-- legal_doc, incident_report, crm_note) is preserved in citation_url
-- (jaffle_logistics://<fine_type>/<id>) and in source_id (chunk_id encodes the source artifact).
{{ config(materialized='table') }}

{{ dbt_context_engineering.knowledge_base([
    {'relation': ref('chunk_embeddings'), 'source_type': 'context_chunk',
     'source_id': 'chunk_id', 'account_key': 'client_id',
     'text': 'chunk_text', 'embedding': 'embedding', 'timestamp': 'artifact_ts',
     'citation_url': 'citation_url'},
    {'relation': ref('ticket_embeddings'), 'source_type': 'ticket',
     'source_id': 'ticket_id', 'account_key': 'client_id',
     'text': 'body', 'embedding': 'embedding', 'timestamp': 'opened_at',
     'citation_url': 'citation_url'}
]) }}
