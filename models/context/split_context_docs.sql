-- Layer-1 splitter (deterministic, zero AI cost): turn each document body into one
-- row per sentence, so chunk() can pack sentences into token-bounded chunks. The
-- boundary rule is naive ([.!?]) and identical on every engine — good enough for a
-- teaching corpus; a production corpus would split with a real tokenizer upstream.
-- Output columns: sentence_id, document_id (= doc_key), sentence_index, sentence_text.
{{ config(materialized='table') }}

{{ dbt_context_engineering.split_sentences(
    relation=ref('int_context_documents'),
    id_column='doc_key',
    text_column='body'
) }}
