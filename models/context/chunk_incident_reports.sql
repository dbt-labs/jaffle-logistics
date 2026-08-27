-- Pack incident report sentences into token-bounded chunks (package
-- chunk(), zero AI-function cost). partition_column = document_id (the
-- report_id) so a chunk never spans two reports.
{{ config(materialized='table') }}

{{ dbt_context_engineering.chunk(
    relation=ref('split_incident_reports'),
    id_column='sentence_id',
    order_column='sentence_index',
    text_column='sentence_text',
    partition_column='document_id'
) }}
