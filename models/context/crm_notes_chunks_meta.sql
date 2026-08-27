-- Carry client_id, citation_url, and artifact_ts onto every CRM-note chunk
-- (attach_metadata: a DISTINCT collapse + join on partition_key, plain
-- portable SQL, zero AI-function cost).
{{ config(materialized='table') }}

{{ dbt_context_engineering.attach_metadata(
    chunks_relation=ref('chunk_crm_notes'),
    metadata_relation=ref('int_crm_notes_documents'),
    metadata_key_column='note_id',
    metadata_columns=['client_id', 'citation_url', 'artifact_ts']
) }}
