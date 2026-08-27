-- content_hash needs a real column upstream of the embedding model (not a
-- same-SELECT alias, BigQuery won't resolve that, and the guard/log can't
-- meter it otherwise). Hash the EXACT string handed to embed() (chunk_text,
-- post-chunking/metadata). transcript_chunks_meta carries client_id and
-- call_date only, so source_type and citation_url (constant per source) are
-- added here rather than a dedicated wrapper model. Zero AI-function cost
-- (still ordinary cloud compute cost on Snowflake/BigQuery/Databricks, free
-- only on local DuckDB).
{{ config(materialized='view') }}

select
    chunk_id,
    partition_key,
    client_id,
    chunk_text,
    'call_transcript'                                                             as source_type,
    'jaffle_logistics://call_transcript/' || cast(partition_key as {{ dbt.type_string() }}) as citation_url,
    cast(call_date as {{ dbt.type_timestamp() }})                                 as artifact_ts,
    {{ dbt_context_engineering.content_hash('chunk_text') }}                     as content_hash
from {{ ref('transcript_chunks_meta') }}
where chunk_text is not null
  and length(trim(chunk_text)) > 0
