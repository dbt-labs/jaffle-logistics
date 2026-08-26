-- Pack transcript turns into token-bounded chunks (package chunk(), pure window
-- SQL, zero AI cost). A chunk never spans a transcript and never splits a turn;
-- each turn's id is carried into source_rows for lineage. speaker prefixes each
-- turn as "speaker: text" inside chunk_text so the embedding/LLM sees who spoke.
{{ config(materialized='table') }}

{{ dbt_context_engineering.chunk(
    relation=ref('int_transcript_turns'),
    id_column='turn_id',
    order_column='turn_index',
    text_column='turn_text',
    partition_column='transcript_id',
    label_column='speaker'
) }}
