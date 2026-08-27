-- Pack legal doc sentences into token-bounded chunks (package chunk(), zero
-- AI-function cost). partition_column = doc_id so a chunk never spans two
-- documents.
{{ config(materialized='table') }}

{{ dbt_context_engineering.chunk(
    relation=ref('split_legal_docs'),
    id_column='sentence_id',
    order_column='sentence_index',
    text_column='sentence_text',
    partition_column='document_id'
) }}
