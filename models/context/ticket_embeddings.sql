-- Phase 3 — governed incremental embedding of whole tickets (REAL Cortex cost). DO
-- NOT run until spend is approved. Same governed pattern as chunk_embeddings; tickets
-- are short enough to embed whole, so the unit is the ticket body (no chunking).
{% set fingerprint = dbt_context_engineering.embedding_fn_fingerprint(model=var('embedding_model')) %}
{% set delta = dbt_context_engineering.incremental_delta_predicate(
    'ticket_id', fingerprint, 'embedding_fn_fingerprint', content_hash_column='content_hash') %}

{{ config(
    materialized='incremental',
    unique_key='ticket_id',
    pre_hook=[
        "{{ dbt_context_engineering.guard_batch(ref('stg_tickets_hashed'), 'body', filter=dbt_context_engineering.incremental_delta_predicate('ticket_id', dbt_context_engineering.embedding_fn_fingerprint(model=var('embedding_model')), 'embedding_fn_fingerprint', content_hash_column='content_hash')) }}",
        "{{ dbt_context_engineering.log_ai_run('embed', model_name=var('embedding_model'), relation=ref('stg_tickets_hashed'), input_column='body', filter=dbt_context_engineering.incremental_delta_predicate('ticket_id', dbt_context_engineering.embedding_fn_fingerprint(model=var('embedding_model')), 'embedding_fn_fingerprint', content_hash_column='content_hash')) }}"
    ],
    post_hook="{{ dbt_context_engineering.complete_ai_run('embed', model_name=var('embedding_model')) }}"
) }}

with embedded as (
    select
        ticket_id,
        client_id,
        opened_at,
        body,
        citation_url,
        content_hash,
        {{ dbt_context_engineering.embed('body') }} as embedding
    from {{ ref('stg_tickets_hashed') }}
    {% if delta %}where {{ delta }}{% endif %}
)

select
    ticket_id,
    client_id,
    opened_at,
    body,
    citation_url,
    content_hash,
    '{{ var("embedding_model") }}'                                 as model_version,
    embedding,
    {{ dbt_context_engineering.embedding_dimension('embedding') }} as embedding_dimension,
    '{{ fingerprint }}'                                            as embedding_fn_fingerprint,
    '{{ run_started_at }}'                                         as embedded_at,
    '{{ dbt_context_engineering.embedding_logic_hash() }}'        as embedding_logic_hash
from embedded
