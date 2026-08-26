-- Phase 3: governed incremental embedding (REAL cloud AI-function cost). DO NOT run until
-- spend is approved.
--
-- Processes only new/changed rows, re-embeds the whole corpus on a model/dimension
-- bump (embedding_fn_fingerprint via version_guard), catches a row whose text changed
-- even when the model didn't (content_hash), guards + logs the DELTA (not the corpus)
-- from one source of truth (incremental_delta_predicate), and stamps the six-column
-- embedding-cache metadata set (ADR-0023). guard_batch and log_ai_run are PRE-hooks
-- because the delta filter derives from `this` (log_ai_run docstring, case 3);
-- complete_ai_run is always a post-hook.
--
-- The AI call (embed) is computed once in the `embedded` CTE, then embedding_dimension
-- reads that stored column, so ai_embed fires exactly once per row, not twice.
--
-- duckdb has no embed() implementation (default__embed raises; same precedent as
-- embedding_canary's duckdb stand-in). This model is never meant to be selected on
-- duckdb, but dbt Jinja-renders every model file during parsing regardless of
-- --select, so an unconditional embed() call here would break parsing project-wide
-- on duckdb. The stand-in keeps parsing green; it proves nothing about real output.
{% set is_duckdb = target.type == 'duckdb' %}
{% set fingerprint = dbt_context_engineering.embedding_fn_fingerprint(model=var('embedding_model')) %}
{% set delta = dbt_context_engineering.incremental_delta_predicate(
    'chunk_id', fingerprint, 'embedding_fn_fingerprint', content_hash_column='content_hash') %}

{{ config(
    materialized='incremental',
    unique_key='chunk_id',
    pre_hook=[
        "{{ dbt_context_engineering.guard_batch(ref('int_chunks_hashed'), 'chunk_text', filter=dbt_context_engineering.incremental_delta_predicate('chunk_id', dbt_context_engineering.embedding_fn_fingerprint(model=var('embedding_model')), 'embedding_fn_fingerprint', content_hash_column='content_hash')) }}",
        "{{ dbt_context_engineering.log_ai_run('embed', model_name=var('embedding_model'), relation=ref('int_chunks_hashed'), input_column='chunk_text', filter=dbt_context_engineering.incremental_delta_predicate('chunk_id', dbt_context_engineering.embedding_fn_fingerprint(model=var('embedding_model')), 'embedding_fn_fingerprint', content_hash_column='content_hash')) }}"
    ],
    post_hook="{{ dbt_context_engineering.complete_ai_run('embed', model_name=var('embedding_model')) }}"
) }}

with embedded as (
    select
        chunk_id,
        client_id,
        source_type,
        citation_url,
        artifact_ts,
        chunk_text,
        content_hash,
        {% if is_duckdb -%}
        [0.0, 0.0, 0.0]
        {%- else -%}
        {{ dbt_context_engineering.embed('chunk_text') }}
        {%- endif %} as embedding
    from {{ ref('int_chunks_hashed') }}
    {% if delta %}where {{ delta }}{% endif %}
)

select
    chunk_id,
    client_id,
    source_type,
    citation_url,
    artifact_ts,
    chunk_text,
    content_hash,
    '{{ var("embedding_model") }}'                                        as model_version,       -- audit only
    embedding,
    {{ dbt_context_engineering.embedding_dimension('embedding') }}        as embedding_dimension,
    '{{ fingerprint }}'                                                   as embedding_fn_fingerprint,
    '{{ run_started_at }}'                                                as embedded_at,
    '{{ dbt_context_engineering.embedding_logic_hash() }}'               as embedding_logic_hash  -- audit only
from embedded
