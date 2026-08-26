-- One row per CRM call transcript. Each links back to the crm_note it
-- transcribes via crm_note_id.
select
    transcript_id,
    crm_note_id,
    client_id,
    cast(call_date as date)     as call_date,
    participants,
    -- body is stored with embedded newlines escaped to '~~NL~~' (portable seed-
    -- loading workaround: some engines reject a quoted CSV field containing a
    -- real newline unless configured otherwise); restore them here.
    replace(body, '~~NL~~', chr(10)) as body
from {{ ref('call_transcripts') }}
