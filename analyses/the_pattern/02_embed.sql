-- embed: same lineage, a populated vector column
select chunk_id, chunk_text, embedding 
from {{ ref('call_transcripts_embed') }}
where chunk_id like 'CT-99001%'
order by chunk_id
