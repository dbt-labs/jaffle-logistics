
  
    

create or replace transient table sthibeault_test_db.dbt_sthibeault.doc_chunks_meta
    
    
    
    as (-- Carry client_id, source_type, and the synthetic citation_url onto every document
-- chunk (attach_metadata, zero AI cost). All three are constant per doc_key, so the
-- DISTINCT collapse yields exactly one row per key; a broken dependency would fan out
-- the join and fail chunk_id uniqueness (loud, by design).


with _ce_metadata as (
    select distinct
        doc_key as _meta_key
        , client_id
        , source_type
        , citation_url
        , artifact_ts
    from sthibeault_test_db.dbt_sthibeault.int_context_documents
),_ce_joined as (
    select
        c.chunk_id,
        c.partition_key,
        c.chunk_seq,
        c.source_rows,
        c.n_source_rows,
        c.chunk_text as chunk_text
        , meta.client_id
        , meta.source_type
        , meta.citation_url
        , meta.artifact_ts
    from sthibeault_test_db.dbt_sthibeault.chunk_docs c
    left join _ce_metadata meta
        on cast(c.partition_key as TEXT) = cast(meta._meta_key as TEXT)
)

select
    chunk_id,
    partition_key,
    chunk_seq,
    source_rows,
    chunk_text,
    n_source_rows,
    ceil(length(chunk_text) / 4.0) as token_estimate
    , client_id
    , source_type
    , citation_url
    , artifact_ts
from _ce_joined
order by partition_key, chunk_seq
    )
;


  