-- Phase 3 — governed incremental embedding (REAL Cortex cost). DO NOT run until
-- spend is approved.
--
-- Processes only new/changed rows, re-embeds the whole corpus on a model/dimension
-- bump (embedding_fn_fingerprint via version_guard), catches a row whose text changed
-- even when the model didn't (content_hash), guards + logs the DELTA (not the corpus)
-- from one source of truth (incremental_delta_predicate), and stamps the six-column
-- embedding-cache metadata set (ADR-0023). guard_batch and log_ai_run are PRE-hooks
-- because the delta filter derives from `this` (log_ai_run docstring, case 3);
-- complete_ai_run is always a post-hook.
--
-- The AI call (embed) is computed once in the `embedded` CTE, then embedding_dimension
-- reads that stored column — so ai_embed fires exactly once per row, not twice.





with embedded as (
    select
        chunk_id,
        client_id,
        source_type,
        citation_url,
        artifact_ts,
        chunk_text,
        content_hash,
        ai_embed('snowflake-arctic-embed-m-v1.5', chunk_text) as embedding
    from sthibeault_test_db.dbt_sthibeault.stg_chunks_hashed
    where chunk_id not in (select chunk_id from sthibeault_test_db.dbt_sthibeault.chunk_embeddings) or (chunk_id, content_hash) not in (select chunk_id, content_hash from sthibeault_test_db.dbt_sthibeault.chunk_embeddings)
)

select
    chunk_id,
    client_id,
    source_type,
    citation_url,
    artifact_ts,
    chunk_text,
    content_hash,
    'snowflake-arctic-embed-m-v1.5'                                        as model_version,       -- audit only
    embedding,
    array_size(embedding)        as embedding_dimension,
    '3217651b87d8be851e8e9c62583061b9'                                                   as embedding_fn_fingerprint,
    '2026-08-25 19:47:21.666469+00:00'                                                as embedded_at,
    '93a0765f23e8758e6de88c722bfd3e4069738f6ce0a04a49e8aaa8a819b48327'               as embedding_logic_hash  -- audit only
from embedded