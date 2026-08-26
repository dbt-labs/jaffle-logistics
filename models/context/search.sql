-- Phase 4 — retrieval demos (REAL Cortex cost: each embeds the query text once). DO
-- NOT run until spend is approved. Brute-force cosine similarity over the knowledge
-- base embedding column (no index needed — the portable, governed baseline). The query
-- is embedded with the SAME model as the corpus.
--
-- Two demos, unioned with a `demo` tag:
--   (a) account-scoped: the Kellerman story across systems (filter on account_key),
--       "late deliveries and renewal risk".
--   (b) thematic (whole corpus): the Chicago winter storm.
--
-- For scale, an opt-in Cortex Search index over knowledge_base is available via
--   dbt run-operation create_vector_index  (separately billed; tear down explicitly).
{{ config(materialized='table') }}

with kellerman as (
    select 'kellerman_renewal_risk' as demo, s.*
    from (
        {{ dbt_context_engineering.vector_search(
            relation=ref('knowledge_base'),
            embedding_column='embedding',
            query_embedding=dbt_context_engineering.embed("'late deliveries and renewal risk'"),
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
            query_embedding=dbt_context_engineering.embed("'truck accident during the Chicago winter storm'"),
            top_k=10,
            id_column='source_id',
            select_columns=['source_type', 'citation_url', 'ts', 'text']
        ) }}
    ) s
)

select * from kellerman
union all
select * from chicago_storm
