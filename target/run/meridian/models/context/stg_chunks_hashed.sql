
  create or replace   view sthibeault_test_db.dbt_sthibeault.stg_chunks_hashed
  
  
  
  
  as (
    -- content_hash needs a real column upstream of the embedding model (not a same-SELECT
-- alias — BigQuery won't resolve that, and the guard/log can't meter it otherwise).
-- This view is that column's one home. Hash the EXACT string handed to embed()
-- (chunk_text, post-chunking/metadata), so a change to assembly that alters the final
-- string is caught. Null/empty text is excluded (see the package's governed-embedding
-- notes). Zero AI cost.


select
    chunk_id,
    client_id,
    source_type,
    citation_url,
    artifact_ts,
    chunk_text,
    sha2(chunk_text, 256) as content_hash
from sthibeault_test_db.dbt_sthibeault.chunks_with_meta
where chunk_text is not null
  and length(trim(chunk_text)) > 0
  );

