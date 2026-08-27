-- Phase 3b: classify each chunk's content type (REAL cloud AI-function cost). DO NOT run until
-- spend is approved. Labels feed knowledge_base's optional `classification` slot (spec: search
-- can filter on content type instead of trusting embedding similarity alone to separate signal
-- from noise; see docs/comparison.md and docs/governance.md for why that matters here).
--
-- Not incremental like chunk_embeddings/ticket_embeddings: classify() has no ADR-0023 cache
-- metadata defined for it the way embed() does. At this demo's corpus size, a full reclassify on
-- every build is a deliberate, disclosed cost tradeoff, not a pattern to copy at real scale.
--
-- duckdb has no classify() implementation (default__classify raises; same precedent as embed's
-- duckdb stand-in). The stand-in keeps parsing green; it proves nothing about real output.
{% set is_duckdb = target.type == 'duckdb' %}

{{ config(
    materialized='table',
    pre_hook=[
        "{{ dbt_context_engineering.guard_batch(ref('int_chunks_hashed'), 'chunk_text') }}",
        "{{ dbt_context_engineering.log_ai_run('classify', model_name='ai_classify (built-in)', relation=ref('int_chunks_hashed'), input_column='chunk_text') }}"
    ],
    post_hook="{{ dbt_context_engineering.complete_ai_run('classify', model_name='ai_classify (built-in)') }}"
) }}

select
    chunk_id,
    {% if is_duckdb -%}
    'vehicle_or_driver_incident'
    {%- else -%}
    {{ dbt_context_engineering.classify(
        'chunk_text',
        prompt=dbt_context_engineering.prompt('jaffle_content_type', 'v1'),
        output_schema=dbt_context_engineering.schema_def('jaffle_content_type', 'v1')
    ) }}
    {%- endif %} as content_type
from {{ ref('int_chunks_hashed') }}
