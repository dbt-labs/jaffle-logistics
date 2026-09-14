-- combine: the union across all five sources
select source_type, account_key, classification, text, embedding, citation_url
from {{ ref('knowledge_base') }}
where account_key = 'CLI-0042'