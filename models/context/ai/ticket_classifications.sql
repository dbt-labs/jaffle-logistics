-- Phase 3b: classify each ticket's content type (REAL cloud AI-function cost). DO NOT run until
-- spend is approved. Same taxonomy and same purpose as chunk_classifications: tickets are the
-- single largest source in knowledge_base by row count, and this project's own search results
-- show routine ticket check-ins crowding out real signal in a plain top-k (see comparison.md).
--
-- Not incremental, same rationale as chunk_classifications: no ADR-0023-style cache for
-- classify(), and a full reclassify each build is a disclosed, demo-scale cost tradeoff.
--
-- duckdb has no classify() implementation; same stand-in precedent as chunk_classifications.
{% set is_duckdb = target.type == 'duckdb' %}

{{ config(
    materialized='table',
    pre_hook=[
        "{{ dbt_context_engineering.guard_batch(ref('int_tickets_hashed'), 'body') }}",
        "{{ dbt_context_engineering.log_ai_run('classify', model_name='ai_classify (built-in)', relation=ref('int_tickets_hashed'), input_column='body') }}"
    ],
    post_hook="{{ dbt_context_engineering.complete_ai_run('classify', model_name='ai_classify (built-in)') }}"
) }}

select
    ticket_id,
    {% if is_duckdb -%}
    'routine_status'
    {%- else -%}
    {{ dbt_context_engineering.classify(
        'body',
        prompt=dbt_context_engineering.prompt('jaffle_content_type', 'v1'),
        output_schema=dbt_context_engineering.schema_def('jaffle_content_type', 'v1')
    ) }}
    {%- endif %} as content_type
from {{ ref('int_tickets_hashed') }}
