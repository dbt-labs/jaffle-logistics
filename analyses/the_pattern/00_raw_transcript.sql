select *
from {{ref('stg_call_transcripts')}}
where transcript_id = 'CT-99001'