-- Phase 4: retrieval demos (REAL cloud AI-function cost: each embeds the query
-- text once). DO
-- NOT run until spend is approved. Brute-force cosine similarity over the knowledge
-- base embedding column (no index needed, the portable, governed baseline). The query
-- is embedded with the SAME model as the corpus.
--
-- Two demos, unioned with a `demo` tag:
--   (a) account-scoped: the Jaffle Equipment story across systems (filter on
--       account_key), "late deliveries and renewal risk".
--   (b) thematic (whole corpus): the Chicago winter storm.
--
-- For scale, an opt-in vector-index service over knowledge_base is available via
--   dbt run-operation create_vector_index (Snowflake Cortex Search, BigQuery vector
--   index; Databricks indexes are created via its own Vector Search API, not SQL,
--   separately billed either way; tear down explicitly).
--
-- duckdb has no embed() implementation (default__embed raises). This model is
-- never meant to be selected on duckdb (knowledge_base itself only holds
-- stand-in vectors there), but the query embeddings still need a stand-in:
-- dbt Jinja-renders every model file during parsing regardless of --select
-- or +enabled, so an unconditional embed() call here would break parsing
-- project-wide on duckdb.
{% set is_duckdb = target.type == 'duckdb' %}
{% set renewal_risk_query = "[0.0, 0.0, 0.0]" if is_duckdb else dbt_context_engineering.embed("'late deliveries and renewal risk'") %}
{% set chicago_storm_query = "[0.0, 0.0, 0.0]" if is_duckdb else dbt_context_engineering.embed("'truck accident during the Chicago winter storm'") %}
{{ config(materialized='table') }}

with jaffle_equipment as (
    select 'jaffle_equipment_renewal_risk' as demo, s.*
    from (
        {{ dbt_context_engineering.vector_search(
            relation=ref('knowledge_base'),
            embedding_column='embedding',
            query_embedding=renewal_risk_query,
            top_k=10,
            id_column='source_id',
            select_columns=['source_type', 'citation_url', 'ts', 'text'],
            filter="account_key = 'CLI-0042'"
        ) }}
    ) s
),

chicago_storm as (
    select 'chicago_winter_storm' as demo, s.*
    from (
        {{ dbt_context_engineering.vector_search(
            relation=ref('knowledge_base'),
            embedding_column='embedding',
            query_embedding=chicago_storm_query,
            top_k=10,
            id_column='source_id',
            select_columns=['source_type', 'citation_url', 'ts', 'text']
        ) }}
    ) s
)

select * from jaffle_equipment
union all
select * from chicago_storm
