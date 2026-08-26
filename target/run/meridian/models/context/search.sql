
  
    

create or replace transient table sthibeault_test_db.dbt_sthibeault.search
    
    
    
    as (-- Phase 4 — retrieval demos (REAL Cortex cost: each embeds the query text once). DO
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


with kellerman as (
    select 'kellerman_renewal_risk' as demo, s.*
    from (
        select
    source_id,
    source_type,citation_url,ts,text,
    vector_cosine_similarity(embedding, ai_embed('snowflake-arctic-embed-m-v1.5', 'late deliveries and renewal risk')) as score
from sthibeault_test_db.dbt_sthibeault.knowledge_base
where account_key = 'CLI-0042'order by score desc, source_id
limit 10
    ) s
),

chicago_storm as (
    select 'chicago_winter_storm' as demo, s.*
    from (
        select
    source_id,
    source_type,citation_url,ts,text,
    vector_cosine_similarity(embedding, ai_embed('snowflake-arctic-embed-m-v1.5', 'truck accident during the Chicago winter storm')) as score
from sthibeault_test_db.dbt_sthibeault.knowledge_base
order by score desc, source_id
limit 10
    ) s
)

select * from kellerman
union all
select * from chicago_storm
    )
;


  