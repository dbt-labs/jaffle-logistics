-- Joins legal_docs_embed to legal_docs_classify on chunk_id. Zero
-- AI-function cost itself (both upstream models already paid for their own
-- AI calls); this just lets knowledge_base's classification slot carry a
-- real content-type label.
{{ config(materialized='table') }}

select
    e.*,
    c.content_type as classification
from {{ ref('legal_docs_embed') }} e
join {{ ref('legal_docs_classify') }} c on c.chunk_id = e.chunk_id
