-- Carry client_id, source_type, and the synthetic citation_url onto every document
-- chunk (attach_metadata, zero AI-function cost). All three are constant per doc_key, so the
-- DISTINCT collapse yields exactly one row per key; a broken dependency would fan out
-- the join and fail chunk_id uniqueness (loud, by design).
{{ config(materialized='table') }}

{{ dbt_context_engineering.attach_metadata(
    chunks_relation=ref('chunk_docs'),
    metadata_relation=ref('int_context_documents'),
    metadata_key_column='doc_key',
    metadata_columns=['client_id', 'source_type', 'citation_url', 'artifact_ts']
) }}
