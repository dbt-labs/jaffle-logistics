-- Pack document sentences into token-bounded chunks (package chunk(), zero AI cost).
-- partition_column = document_id (the doc_key) so a chunk never spans two documents;
-- each sentence id is carried into source_rows for lineage.
{{ config(materialized='table') }}

{{ dbt_context_engineering.chunk(
    relation=ref('split_context_docs'),
    id_column='sentence_id',
    order_column='sentence_index',
    text_column='sentence_text',
    partition_column='document_id'
) }}
