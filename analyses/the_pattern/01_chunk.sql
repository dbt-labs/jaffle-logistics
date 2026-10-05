-- chunk: query the built table, find the CT-99001 boundary
-- (transcript_chunks_meta = chunk_transcripts + client_id/call_date attached)
select chunk_id, chunk_seq, chunk_text
from {{ ref('transcript_chunks_meta') }}
where chunk_id like 'CT-99001%'
order by chunk_seq
