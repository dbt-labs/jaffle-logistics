
  
    

create or replace transient table sthibeault_test_db.dbt_sthibeault.chunks_with_meta
    
    
    
    as (-- The unified chunk corpus: every metadata-carrying chunk from both pipelines
-- (transcripts + documents) in one common shape, ready to embed. This is the last
-- ZERO-COST layer — the clean gate before any Cortex spend. The Phase 3 embedding
-- models read straight from here.
--
-- Common columns: chunk_id, partition_key (the source artifact id), chunk_seq,
-- source_rows (lineage), chunk_text, n_source_rows, token_estimate, client_id
-- (account key; null for un-scopable rows), source_type, citation_url, artifact_ts
-- (the source document's date — powers date-ordered narrative retrieval).


with transcripts as (
    select
        chunk_id,
        partition_key,
        chunk_seq,
        source_rows,
        chunk_text,
        n_source_rows,
        token_estimate,
        client_id,
        'call_transcript'                                                       as source_type,
        'meridian://call_transcript/' || cast(partition_key as TEXT) as citation_url,
        cast(call_date as timestamp)                           as artifact_ts
    from sthibeault_test_db.dbt_sthibeault.transcript_chunks_meta
),

docs as (
    select
        chunk_id,
        partition_key,
        chunk_seq,
        source_rows,
        chunk_text,
        n_source_rows,
        token_estimate,
        client_id,
        source_type,
        citation_url,
        artifact_ts
    from sthibeault_test_db.dbt_sthibeault.doc_chunks_meta
)

select * from transcripts
union all
select * from docs
    )
;


  