
  
    

create or replace transient table sthibeault_test_db.dbt_sthibeault.transcript_chunks_meta
    
    
    
    as (-- Carry the transcript's client_id onto every transcript chunk (attach_metadata:
-- a DISTINCT collapse + join on partition_key, plain portable SQL, zero AI cost).
-- source_type and citation_url are added in chunks_with_meta (constant for this
-- source), keeping the metadata_relation here to the columns it actually holds.


with _ce_metadata as (
    select distinct
        transcript_id as _meta_key
        , client_id
        , call_date
    from sthibeault_test_db.dbt_sthibeault.stg_call_transcripts
),_ce_joined as (
    select
        c.chunk_id,
        c.partition_key,
        c.chunk_seq,
        c.source_rows,
        c.n_source_rows,
        c.chunk_text as chunk_text
        , meta.client_id
        , meta.call_date
    from sthibeault_test_db.dbt_sthibeault.chunk_transcripts c
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
    , call_date
from _ce_joined
order by partition_key, chunk_seq
    )
;


  