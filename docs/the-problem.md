# The problem: reconstructing a story from joins alone

Before any AI function is involved, this project builds the best
deterministic answer it can. That's the real baseline the
context-engineering layer has to improve on.

## Stitching touchpoints together

[`int_shipment_touchpoints`](https://github.com/dbt-labs/jaffle-logistics/blob/main/models/intermediate/int_shipment_touchpoints.sql)
is the heart of that baseline: one row per artifact that references a
shipment, unioned across every source that can carry a shipment ID.

Most sources make this easy. Support tickets, incidents, CRM notes, and
incident reports all carry a typed `shipment_id` column, so pulling them
together is a plain union.

Two sources don't:

- **Dispatch notes** name a failed stop's shipment inside a terse,
  free-text ops log, for example `SHP-240817-004291 missed window, driver
  rerouted`. The only way to pull a shipment ID out of that is a regex:
  `SHP-[0-9]{6}-[0-9]{6}`.
- **Call transcripts** never mention a shipment ID at all. They inherit
  one indirectly, through the CRM note they transcribe.

Slack threads go a step further: they don't reference a shipment or a
parcel ID at all, only the incident they discuss. Reaching a shipment from
a Slack thread means an extra hop, incident to shipment, that
`int_shipment_touchpoints` doesn't even attempt.

Here's what the actual output looks like, an early slice of
`int_shipment_touchpoints` ordered by date:

| shipment_id | source | artifact_id | occurred_at | snippet |
|---|---|---|---|---|
| SHP-202508-000053 | incident | INC-2025-00021 | 2025-01-01 14:30 | Weather event (severity 1) at Indianapolis. |
| SHP-202501-000177 | support_ticket | TKT-200228 | 2025-01-03 17:06 | Following up on SHP-202501-000177, could you send the POD once it's delivered... |
| SHP-202501-000308 | support_ticket | TKT-200018 | 2025-01-05 15:53 | Extremely disappointed. SHP-202501-000308 was marked delayed with... |
| SHP-202509-000289 | incident | INC-2025-00139 | 2025-01-09 14:32 | Mispick event (severity 3) at Indianapolis. |

Ordinary rows, each one an exact match on a structured column.

### The regex case, concretely

A dispatch note's raw body, before extraction:

```
[01/13 15:26] RTE-IND-20250113-002 / DRV-01006 @ IND
Bad address on SHP-202501-000070. Geocode off by ~3mi. Held for dispatch correction.
```

Run through `{{ regex_first('body', 'SHP-[0-9]{6}-[0-9]{6}') }}`, that
becomes one clean touchpoint row:

| shipment_id | source | artifact_id | occurred_at | snippet |
|---|---|---|---|---|
| SHP-202501-000070 | dispatch_note | DN-100003 | 2025-01-13 15:26 | [01/13 15:26] RTE-IND-20250113-002 / DRV-01006 @ IND. Bad address on SHP-202501-000070... |

That works because the ID pattern is fixed and always spelled out
verbatim. Anything the note describes without naming an ID this way, a
delay explained in prose instead of a shipment number, is invisible to
this regex.

### The inheritance case, concretely

`CT-99001`, a call transcript, never mentions `SHP-202501-900001` itself.
It only reaches that shipment by joining through the CRM note it
transcribes (`CRM-9001`):

| shipment_id | source | artifact_id | occurred_at | snippet |
|---|---|---|---|---|
| SHP-202501-900001 | call_transcript | CT-99001 | 2025-01-21 | [CALL TRANSCRIPT — Jaffle Equipment (CLI-0042) \| QBR 2025-01-21 \| ref CRM-9001] [Marcus Trent — Jaffle Logistics]: Janet, thanks for taking this... |

One more join hop than the tickets and incidents needed, and still built
entirely on an exact key match (`crm_note_id`), not on anything read from
the transcript's actual words.

## The narrative query

[`jaffle_equipment_narrative.sql`](https://github.com/dbt-labs/jaffle-logistics/blob/main/analyses/jaffle_equipment_narrative.sql)
is the payoff of that baseline: every artifact touching the Jaffle
Equipment account (`CLI-0042`), in date order, reconstructed purely from
joins and a regex. It combines two things:

1. Artifacts stitched to a Jaffle Equipment shipment via
   `int_shipment_touchpoints`.
2. Artifacts tied to the account directly, no shipment involved: CRM
   notes, legal docs, support tickets, and call transcripts filtered on
   `client_id`, plus Slack threads matched with a `like '%CLI-0042%'`
   against the thread body.

Run against seed data with thousands of unrelated records across five
Jaffle-branded accounts, this query works. It produces a coherent,
date-ordered account story.

## Where it runs out of road

The query works because every match it relies on is exact: a
`client_id`, a `shipment_id`, a regex against a fixed ID pattern, a `like`
against a literal string. That's also its ceiling.

Ask the query to find every mention of "late deliveries and what's
driving them," or a truck accident during a specific storm, and there's
nothing to join on. Those are ideas, not IDs. A dispatch note that
describes a delay without naming the shipment, a Slack thread where ops
flags a pattern without citing an incident ID yet, a legal doc that
references an incident by date instead of ID: none of that surfaces
through a join.

This is a ceiling on exact-match SQL, not on SQL itself. Getting past it
with more SQL means writing a new regex or `like` pattern for every
phrase you might care about, in advance, hoping the free text contains
that phrase verbatim. The query stays fast at any data volume; the
problem is coverage, not speed. Each new question needs another
hand-written pattern, written before you know what the data actually
says. [Context engineering](context-engineering.md) is SQL that can call an
embedding function instead, still dbt, still SQL, just not limited to
matching what you already knew to look for.
