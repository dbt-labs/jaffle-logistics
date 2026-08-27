-- Classify each support-ticket record's content type (REAL cloud
-- AI-function cost). DO NOT run until spend is approved. Same taxonomy and
-- prompt as every other source's classify model (jaffle_content_type v1):
-- this is a worked example, so one shared taxonomy across all five sources
-- is deliberate. In a real system with genuinely different content per
-- source, diverging the prompt per source would be the realistic next step.
--
-- Not incremental: classify() has no dbt_context_engineering ADR-0023 cache metadata the way
-- embed() does, so every build reclassifies the whole corpus, a deliberate,
-- disclosed cost tradeoff at this demo's scale.
--
-- duckdb has no classify() implementation (default__classify raises). The
-- stand-in keeps parsing green; it proves nothing about real output.
{% set is_duckdb = target.type == 'duckdb' %}

{{ config(
    materialized='table',
    pre_hook=[
        "{{ dbt_context_engineering.guard_batch(ref('support_tickets_hashed'), 'chunk_text') }}",
        "{{ dbt_context_engineering.log_ai_run('classify', model_name='ai_classify (built-in)', relation=ref('support_tickets_hashed'), input_column='chunk_text') }}"
    ],
    post_hook="{{ dbt_context_engineering.complete_ai_run('classify', model_name='ai_classify (built-in)') }}"
) }}

select
    chunk_id,
    {% if is_duckdb -%}
    'routine_status'
    {%- else -%}
    {{ dbt_context_engineering.classify(
        'chunk_text',
        prompt=dbt_context_engineering.prompt('jaffle_content_type', 'v1'),
        output_schema=dbt_context_engineering.schema_def('jaffle_content_type', 'v1')
    ) }}
    {%- endif %} as content_type
from {{ ref('support_tickets_hashed') }}
