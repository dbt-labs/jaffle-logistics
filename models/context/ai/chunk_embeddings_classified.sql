-- Joins chunk_embeddings to chunk_classifications on chunk_id. Zero AI-function cost itself
-- (both upstream models already paid for their own AI calls); this just lets knowledge_base's
-- optional `classification` slot carry a real content-type label per chunk.
{{ config(materialized='table') }}

select
    ce.*,
    cc.content_type as classification
from {{ ref('chunk_embeddings') }} ce
join {{ ref('chunk_classifications') }} cc on cc.chunk_id = ce.chunk_id
