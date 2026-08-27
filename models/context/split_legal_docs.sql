-- Layer-1 splitter for legal docs (deterministic, zero AI-function cost):
-- one row per sentence, feeding chunk_legal_docs.
{{ config(materialized='table') }}

{{ dbt_context_engineering.split_sentences(
    relation=ref('int_legal_docs_documents'),
    id_column='doc_id',
    text_column='body'
) }}
