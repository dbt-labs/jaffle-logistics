-- Governed incremental embedding of support-ticket records (REAL cloud
-- AI-function cost). DO NOT run until spend is approved. Same governed
-- pattern as legal_docs_embed.sql; the embedding unit is the whole ticket
-- body (ticket_records_meta deliberately never calls chunk()).
--
-- duckdb has no embed() implementation (default__embed raises); the
-- stand-in keeps parsing green, proves nothing about real output. Cast to a
-- fixed-size ARRAY (double[3]), not a LIST (double[]): duckdb's
-- array_cosine_similarity (used by search.sql) only accepts the former.
{% set is_duckdb = target.type == 'duckdb' %}
{% set fingerprint = dbt_context_engineering.embedding_fn_fingerprint(model=var('embedding_model')) %}
{% set delta = dbt_context_engineering.incremental_delta_predicate(
    'chunk_id', fingerprint, 'embedding_fn_fingerprint', content_hash_column='content_hash') %}

{{ config(
    materialized='incremental',
    unique_key='chunk_id',
    pre_hook=[
        "{{ dbt_context_engineering.guard_batch(ref('support_tickets_hashed'), 'chunk_text', filter=dbt_context_engineering.incremental_delta_predicate('chunk_id', dbt_context_engineering.embedding_fn_fingerprint(model=var('embedding_model')), 'embedding_fn_fingerprint', content_hash_column='content_hash')) }}",
        "{{ dbt_context_engineering.log_ai_run('embed', model_name=var('embedding_model'), relation=ref('support_tickets_hashed'), input_column='chunk_text', filter=dbt_context_engineering.incremental_delta_predicate('chunk_id', dbt_context_engineering.embedding_fn_fingerprint(model=var('embedding_model')), 'embedding_fn_fingerprint', content_hash_column='content_hash')) }}"
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
        cast([0.0, 0.0, 0.0] as double[3])
        {%- else -%}
        {{ dbt_context_engineering.embed('chunk_text') }}
        {%- endif %} as embedding
    from {{ ref('support_tickets_hashed') }}
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
