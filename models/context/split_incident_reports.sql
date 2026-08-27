-- Layer-1 splitter for incident reports (deterministic, zero AI-function
-- cost): one row per sentence, feeding chunk_incident_reports.
{{ config(materialized='table') }}

{{ dbt_context_engineering.split_sentences(
    relation=ref('int_incident_reports_documents'),
    id_column='report_id',
    text_column='body'
) }}
