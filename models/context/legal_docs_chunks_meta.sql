-- Carry client_id, citation_url, and artifact_ts onto every legal-doc chunk
-- (attach_metadata: a DISTINCT collapse + join on partition_key, plain
-- portable SQL, zero AI-function cost).
{{ config(materialized='table') }}

{{ dbt_context_engineering.attach_metadata(
    chunks_relation=ref('chunk_legal_docs'),
    metadata_relation=ref('int_legal_docs_documents'),
    metadata_key_column='doc_id',
    metadata_columns=['client_id', 'citation_url', 'artifact_ts']
) }}
