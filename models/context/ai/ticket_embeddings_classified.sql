-- Joins ticket_embeddings to ticket_classifications on ticket_id. Same purpose as
-- chunk_embeddings_classified: zero additional AI-function cost, just carries the real
-- content-type label into knowledge_base's optional `classification` slot.
{{ config(materialized='table') }}

select
    te.*,
    tc.content_type as classification
from {{ ref('ticket_embeddings') }} te
join {{ ref('ticket_classifications') }} tc on tc.ticket_id = te.ticket_id
