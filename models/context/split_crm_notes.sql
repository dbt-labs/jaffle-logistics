-- Layer-1 splitter for CRM notes (deterministic, zero AI-function cost):
-- one row per sentence, feeding chunk_crm_notes.
{{ config(materialized='table') }}

{{ dbt_context_engineering.split_sentences(
    relation=ref('int_crm_notes_documents'),
    id_column='note_id',
    text_column='body'
) }}
