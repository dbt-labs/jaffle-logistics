-- One row per CRM call transcript. Each links back to the crm_note it
-- transcribes via crm_note_id.
select
    transcript_id,
    crm_note_id,
    client_id,
    cast(call_date as date)     as call_date,
    participants,
    body
from {{ ref('call_transcripts') }}
