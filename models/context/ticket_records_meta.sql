-- Deliberately NOT chunked (contrast with chunk_transcripts / chunk_legal_docs /
-- chunk_incident_reports / chunk_crm_notes): a support ticket body is already the
-- atomic embedding unit, so this reshapes it straight to the chunk-shaped output
-- instead of calling chunk(). No packing/window SQL, no split_sentences step;
-- chunk_seq is always 1 by construction, not by an assumption about ticket length.
-- Feeds support_tickets_hashed directly; unlike the other four sources it has no
-- upstream chunker of its own to converge with.
{{ config(materialized='table') }}

select
    ticket_id || '::1'                                     as chunk_id,
    ticket_id                                              as partition_key,
    1                                                       as chunk_seq,
    {{ dbt_context_engineering.array_agg('ticket_id', 'ticket_id') }} as source_rows,
    body                                                    as chunk_text,
    1                                                       as n_source_rows,
    ceil(length(body) / 4.0)                                as token_estimate,
    client_id,
    'support_ticket'                                        as source_type,
    'jaffle_logistics://support_ticket/' || ticket_id       as citation_url,
    cast(opened_at as {{ dbt.type_timestamp() }})           as artifact_ts
from {{ ref('stg_support_tickets') }}
group by ticket_id, body, client_id, opened_at
