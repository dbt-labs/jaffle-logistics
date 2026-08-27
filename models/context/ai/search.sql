-- Phase 4: retrieval demos (REAL cloud AI-function cost: each embeds the query
-- text once). DO
-- NOT run until spend is approved. Brute-force cosine similarity over the knowledge
-- base embedding column (no index needed, the portable, governed baseline). The query
-- is embedded with the SAME model as the corpus.
--
-- Two demos, each run twice (raw, then filtered on knowledge_base's classification
-- column), unioned with a `demo` tag:
--   (a) account-scoped: the Jaffle Equipment story across systems (filter on
--       account_key), "late deliveries and what is driving them".
--   (b) thematic (whole corpus): the Chicago winter storm.
-- The raw runs are kept, not replaced, on purpose: docs/comparison.md's claim is a
-- real before/after, not just an after. The filtered runs use knowledge_base's
-- classification column (a real classify() label, one flat enum: account_assessment /
-- contract_reference / weather_disruption / vehicle_or_driver_incident /
-- handling_or_warehouse_error / routine_status) to match the filter to each query's own
-- intent: the account-scoped demo wants account_assessment content, the whole-corpus
-- storm query wants weather_disruption content. An earlier, coarser taxonomy
-- (account_assessment / incident_record / contract_reference) fixed the account demo but
-- did nothing for the storm demo, every top result was already 'incident_record', so the
-- filter had nothing to exclude. See docs/comparison.md and docs/governance.md for both
-- results and what changed.
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
{% set performance_query = "cast([0.0, 0.0, 0.0] as double[3])" if is_duckdb else dbt_context_engineering.embed("'late deliveries and what is driving them'") %}
{% set chicago_storm_query = "cast([0.0, 0.0, 0.0] as double[3])" if is_duckdb else dbt_context_engineering.embed("'truck accident during the Chicago winter storm'") %}
{{ config(materialized='table') }}

with jaffle_equipment as (
    select 'jaffle_equipment_performance_issues' as demo, s.*
    from (
        {{ dbt_context_engineering.vector_search(
            relation=ref('knowledge_base'),
            embedding_column='embedding',
            query_embedding=performance_query,
            top_k=10,
            id_column='source_id',
            select_columns=['source_type', 'citation_url', 'ts', 'text', 'classification'],
            filter="account_key = 'CLI-0042'"
        ) }}
    ) s
),

jaffle_equipment_classified as (
    select 'jaffle_equipment_performance_issues_classified' as demo, s.*
    from (
        {{ dbt_context_engineering.vector_search(
            relation=ref('knowledge_base'),
            embedding_column='embedding',
            query_embedding=performance_query,
            top_k=10,
            id_column='source_id',
            select_columns=['source_type', 'citation_url', 'ts', 'text', 'classification'],
            filter="account_key = 'CLI-0042' and classification = 'account_assessment'"
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
            select_columns=['source_type', 'citation_url', 'ts', 'text', 'classification']
        ) }}
    ) s
),

chicago_storm_classified as (
    select 'chicago_winter_storm_classified' as demo, s.*
    from (
        {{ dbt_context_engineering.vector_search(
            relation=ref('knowledge_base'),
            embedding_column='embedding',
            query_embedding=chicago_storm_query,
            top_k=10,
            id_column='source_id',
            select_columns=['source_type', 'citation_url', 'ts', 'text', 'classification'],
            filter="classification = 'weather_disruption'"
        ) }}
    ) s
)

select * from jaffle_equipment
union all
select * from jaffle_equipment_classified
union all
select * from chicago_storm
union all
select * from chicago_storm_classified
