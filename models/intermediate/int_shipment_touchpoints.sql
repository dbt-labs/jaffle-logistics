-- The heart of the "context stitching" demo: every artifact that references a
-- shipment, unioned into one long, queryable table. Most sources carry a typed
-- shipment_id column (tickets, incidents, CRM notes, incident reports) — the
-- realistic home for a shipment reference. Two do not: a dispatch note names the
-- failed stop's shipment inside terse free text (extracted with a regex), and a
-- call transcript reaches its shipment through the CRM note it transcribes.
-- Slack threads intentionally do NOT reference parcel IDs; they reach a shipment
-- via the incident they discuss (incident -> shipment_id), so they are not a
-- direct source here.
--
-- Grain: one row per (source, artifact, shipment_id). touchpoint_key is unique.

{% set shp_re = 'SHP-[0-9]{6}-[0-9]{6}' %}

with tickets as (
    select
        shipment_id,
        'support_ticket'        as source,
        ticket_id               as artifact_id,
        opened_at               as occurred_at,
        left(body, 160)         as snippet
    from {{ ref('stg_support_tickets') }}
    where shipment_id is not null
),

incidents as (
    select
        shipment_id,
        'incident'              as source,
        incident_id             as artifact_id,
        occurred_at,
        summary                 as snippet
    from {{ ref('stg_incidents') }}
    where shipment_id is not null
),

-- CRM notes: shipment lives in a structured column (most notes are account-level
-- with a null shipment_id)
crm as (
    select
        shipment_id,
        'crm_note'              as source,
        note_id                 as artifact_id,
        cast(call_date as timestamp) as occurred_at,
        left(body, 160)         as snippet
    from {{ ref('stg_crm_notes') }}
    where shipment_id is not null
),

-- incident reports: affected shipment is a structured column
reports as (
    select
        shipment_id,
        'incident_report'       as source,
        report_id               as artifact_id,
        filed_at                as occurred_at,
        left(body, 160)         as snippet
    from {{ ref('stg_incident_reports') }}
    where shipment_id is not null
),

-- call transcripts inherit their shipment from the CRM note they transcribe;
-- no parcel IDs are spoken in the transcript itself
transcripts as (
    select
        n.shipment_id,
        'call_transcript'       as source,
        t.transcript_id         as artifact_id,
        cast(t.call_date as timestamp) as occurred_at,
        left(t.body, 160)       as snippet
    from {{ ref('stg_call_transcripts') }} t
    join {{ ref('stg_crm_notes') }} n on n.note_id = t.crm_note_id
    where n.shipment_id is not null
),

-- dispatch notes: the one realistic free-text case — a terse ops log naming the
-- failed stop's shipment, extracted with a regex (first match; a note names at
-- most one shipment)
dispatch as (
    select
        {{ regex_first('body', shp_re) }} as shipment_id,
        'dispatch_note'         as source,
        note_id                 as artifact_id,
        noted_at                as occurred_at,
        left(body, 160)         as snippet
    from {{ ref('stg_dispatch_notes') }}
    where {{ has_match('body', shp_re) }}
),

unioned as (
    select * from tickets
    union all select * from incidents
    union all select * from crm
    union all select * from reports
    union all select * from transcripts
    union all select * from dispatch
),

-- an artifact can name the same shipment more than once (e.g. a dispatch note
-- repeating the ID); collapse to one row per artifact+shipment
deduped as (
    select
        shipment_id, source, artifact_id,
        min(occurred_at)                as occurred_at,
        min(snippet)                    as snippet
    from unioned
    group by shipment_id, source, artifact_id
)

select
    source || ':' || artifact_id || ':' || shipment_id as touchpoint_key,
    shipment_id,
    source,
    artifact_id,
    occurred_at,
    snippet
from deduped
