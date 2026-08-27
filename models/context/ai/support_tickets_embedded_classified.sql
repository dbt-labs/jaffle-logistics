-- Joins support_tickets_embed to support_tickets_classify on chunk_id. Zero
-- AI-function cost itself (both upstream models already paid for their own
-- AI calls); this just lets knowledge_base's classification slot carry a
-- real content-type label.
{{ config(materialized='table') }}

select
    e.*,
    c.content_type as classification
from {{ ref('support_tickets_embed') }} e
join {{ ref('support_tickets_classify') }} c on c.chunk_id = e.chunk_id
