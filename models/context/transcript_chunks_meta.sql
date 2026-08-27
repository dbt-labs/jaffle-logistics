-- Carry the transcript's client_id onto every transcript chunk (attach_metadata:
-- a DISTINCT collapse + join on partition_key, plain portable SQL, zero AI-function cost).
-- source_type and citation_url are added in call_transcripts_hashed (constant for
-- this source), keeping the metadata_relation here to the columns it actually holds.
{{ config(materialized='table') }}

{{ dbt_context_engineering.attach_metadata(
    chunks_relation=ref('chunk_transcripts'),
    metadata_relation=ref('stg_call_transcripts'),
    metadata_key_column='transcript_id',
    metadata_columns=['client_id', 'call_date']
) }}
