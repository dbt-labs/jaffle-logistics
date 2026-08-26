-- NARRATIVE query (the "signal"): every artifact touching the Kellerman account
-- (CLI-0042), in date order — reconstructed purely from joins/regex. Combines
-- artifacts tied to Kellerman directly (by client_id or a CLI-0042 mention) with
-- every artifact stitched to a Kellerman shipment via int_shipment_touchpoints.
-- This is the payoff: a coherent storyline assembled from fragments scattered
-- across eight systems, against a background of thousands of unrelated records.



with k_shipments as (
    select shipment_id from sthibeault_test_db.dbt_sthibeault.stg_shipments where client_id = 'CLI-0042'
),

-- 1. artifacts stitched to a Kellerman shipment (tickets, incidents, dispatch,
--    slack, crm, incident reports) via the touchpoints model
via_shipment as (
    select tp.occurred_at, tp.source, tp.artifact_id,
           tp.shipment_id as ref_id, tp.snippet
    from sthibeault_test_db.dbt_sthibeault.int_shipment_touchpoints tp
    join k_shipments k on k.shipment_id = tp.shipment_id
),

-- 2. artifacts tied directly to the account (client-level, no shipment)
direct_crm as (
    select cast(call_date as timestamp) as occurred_at, 'crm_note' as source,
           note_id as artifact_id, 'CLI-0042' as ref_id, left(body, 160) as snippet
    from sthibeault_test_db.dbt_sthibeault.stg_crm_notes where client_id = 'CLI-0042'
),
direct_legal as (
    select cast(effective_date as timestamp) as occurred_at, 'legal_doc' as source,
           doc_id as artifact_id, 'CLI-0042' as ref_id, left(body, 160) as snippet
    from sthibeault_test_db.dbt_sthibeault.stg_legal_docs where client_id = 'CLI-0042'
),
direct_slack as (
    select started_at as occurred_at, 'slack_thread' as source,
           thread_id as artifact_id, 'CLI-0042' as ref_id, left(body, 160) as snippet
    from sthibeault_test_db.dbt_sthibeault.stg_slack_threads
    where linked_ids like '%CLI-0042%' or body like '%CLI-0042%'
),
direct_tickets as (
    select opened_at as occurred_at, 'support_ticket' as source,
           ticket_id as artifact_id, 'CLI-0042' as ref_id, left(body, 160) as snippet
    from sthibeault_test_db.dbt_sthibeault.stg_support_tickets where client_id = 'CLI-0042'
),
-- verbatim QBR call transcripts for the account, linked via crm_note_id
direct_transcripts as (
    select cast(call_date as timestamp) as occurred_at, 'call_transcript' as source,
           transcript_id as artifact_id, crm_note_id as ref_id, left(body, 160) as snippet
    from sthibeault_test_db.dbt_sthibeault.stg_call_transcripts where client_id = 'CLI-0042'
)

select * from via_shipment
union
select * from direct_crm
union
select * from direct_legal
union
select * from direct_slack
union
select * from direct_tickets
union
select * from direct_transcripts
order by occurred_at