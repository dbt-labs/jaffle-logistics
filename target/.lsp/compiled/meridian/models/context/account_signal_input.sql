-- Input for the account-signal extraction: the account-narrative chunks only
-- (transcripts + CRM notes), pre-filtered so the AI model, its guard, and its run-log
-- all reference one clean relation with no inline filter to keep in sync. Zero cost
-- (a view over the already-built chunk corpus).


select
    chunk_id,
    client_id,
    source_type,
    citation_url,
    artifact_ts,
    chunk_text
from sthibeault_test_db.dbt_sthibeault.chunks_with_meta
where source_type in ('call_transcript', 'crm_note')