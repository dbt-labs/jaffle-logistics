# Comparison: two narratives, one account

The same account's story, told twice: once by hand-written joins, once
by semantic retrieval. Both ran against real data. The join returns
every artifact tied to the account by an exact identifier, all 181 rows
of it; the coherent narrative below exists only because eight of those
rows were picked out by hand. Semantic retrieval does better than manual assembly, but only once it
moves past raw cosine similarity. Raw similarity fails for a specific,
tested reason; a business-scoped `classify()` pass fixes most of it,
and that improvement is what this page demonstrates.

## The account: Jaffle Equipment (`CLI-0042`)

On-time delivery for Jaffle Equipment degraded through 2025 for two
unrelated reasons, documented across CRM notes, support tickets, Slack,
and incident reports.

Pulled straight from `jaffle_equipment_narrative.sql`'s actual output
(181 rows total; support tickets alone account for 144), here are the
beats that turn a wall of tickets into a root-cause story:

| occurred_at | source | artifact_id | excerpt |
|---|---|---|---|
| 2023-11-14 | legal_doc | LGL-4000 | MASTER SERVICES AGREEMENT — Jaffle Logistics and Jaffle Equipment (CLI-0042). Effective 2023-11-14... |
| 2025-01-21 | crm_note | CRM-9001 | QBR — Jaffle Equipment (CLI-0042), Q1 2025. Tense call. The Jan 14-16 Chicago storm delayed a large batch of Jaffle Equipment freight... |
| 2025-01-21 | call_transcript | CT-99001 | Marcus Trent: Janet, thanks for taking this. I know the last two weeks have been rough, I want to own it... |
| 2025-07-18 | slack_thread | SLK-99010 | @marcus: on-time for Jaffle Equipment (CLI-0042) has been sliding since Q2, and tickets are up. @marcus: storm recovery mostly explains CHI, but I'm also seeing two damage/mispick incidents at CMH in June that don't fit that pattern... |
| 2025-10-11 | incident_report | IR-9003 | INCIDENT REPORT INC-2025-00095 — DAMAGE (severity 3). This is the third handling-related incident at HUB-CMH in 2025, following a damage event in June (INC-2025-00136) and a mispick eight days later (INC-2025-00241)... |
| 2025-10-14 | crm_note | CRM-9022 | QBR — Jaffle Equipment (CLI-0042), Q3 2025. On-time is materially under target. The January Chicago storm explains part of it, but a second, weather-independent pattern has emerged: repeated handling damage at the Columbus hub... |
| 2025-10-15 | slack_thread | SLK-99011 | @marcus: third CMH incident this year for Jaffle Equipment (INC-2025-00095, damage) — same pattern as INC-2025-00136 and INC-2025-00241. @gordon: bay 3 forklift staging has come up before... |
| 2025-10-20 | crm_note | CRM-9030 | Q4 PERFORMANCE ROOT-CAUSE REVIEW — Jaffle Equipment (CLI-0042). Two contributing factors identified for 2025's on-time decline: the January Chicago winter storm, and a recurring handling-damage pattern at the Columbus hub... |

Contract signed, a one-time storm spikes ticket volume in January, an
unrelated handling pattern emerges at Columbus over the summer. Ops
traces it to a specific bay, and the Q4 review documents both causes
side by side, each backed by an incident ID. All eight rows exist in the
181-row output today; finding them meant scrolling past 173 others.

## Told by joins

[`jaffle_equipment_narrative.sql`](https://github.com/dbt-labs/jaffle-logistics/blob/main/analyses/jaffle_equipment_narrative.sql)
reconstructs the account's full history in date order using `client_id`
matches, `int_shipment_touchpoints` joins, and a `like '%CLI-0042%'`
pattern for Slack. It surfaces every artifact tied to the account by an
exact identifier. It has no opinion about which artifacts matter, and it
can't find anything the account mentions without naming it explicitly.

## Told by search, raw

The same account, asked differently: `search.sql`'s
`jaffle_equipment_performance_issues` demo embeds "late deliveries and
what is driving them" once, then runs cosine similarity over
`knowledge_base`, filtered to `account_key = 'CLI-0042'`. No join, no
regex, no exact string.

The real top 10 on Snowflake:

| rank | source_id | score | what it actually is |
|---|---|---|---|
| 1 | `IR-9001::3` | 0.754 | a six-token trailing sentence: "Reviewed with dispatch." |
| 2 | `IR-7003::2` | 0.658 | an unrelated incident's root-cause/remediation lines |
| 3 | `IR-7013::2` | 0.641 | another unrelated incident's remediation line |
| 4, 6, 8-10 | `TKT-2000xx` | 0.55-0.58 | routine "can you confirm the delivery window" check-ins |
| 5 | `IR-7009::2` | 0.572 | another unrelated incident's remediation line |
| 7 | `CT-99021::2` | 0.565 | real signal: "I'll bring findings next time, not just a promise" |

One real hit makes the top 10 on its own. `CRM-9030`, `CRM-9022`, and
the rest of the QBR arc don't. Six of the ten slots are boilerplate from
unrelated incidents or routine ticket check-ins.

Cosine similarity favors short or formulaic text over topically relevant
text: that text sits close to the center of embedding space, so it
scores high against almost any query, regardless of topic. The most
duplicated incident-report boilerplate accounts for some of this
(rewriting it into distinct phrasing changes those specific scores), but
not `IR-9001::3`, which was never duplicated anywhere and doesn't move.
Duplicate content and short, low-information chunks are separate
problems (see [governance](governance.md)).

## Fixing it with classify()

Each source's `*_classify` model labels every chunk and ticket record
by content type, sharing one taxonomy and prompt across all five:
`account_assessment`, `contract_reference`,
`weather_disruption`, `vehicle_or_driver_incident`,
`handling_or_warehouse_error`, or `routine_status`. Each label is a
business category, not a judgment of how well the text is written, and
it matches the weather-vs-handling split `CRM-9030`'s own root-cause
review makes.

This taxonomy was designed for these two demo queries specifically. It's
not a general-purpose, first-principles categorization validated
against arbitrary future questions; that's separate work, covered in
[roadmap](roadmap.md). What follows is real `classify()` output against
real data, a demonstration of the mechanism, not proof it generalizes.

Filtered to `classification = 'account_assessment'`:

| rank | source_id | score | what it is |
|---|---|---|---|
| 1 | `CT-99021::2` | 0.565 | Q2 transcript close: "I'll bring findings next time" |
| 2 | `CT-99021::1` | 0.544 | Q2 transcript open: pattern flagged, cause unknown |
| 3 | `CT-99022::1` | 0.501 | Q3 transcript: Columbus pattern identified |
| 4 | `IR-9003::2` | 0.491 | the Columbus incident report's own account-facing note |
| 5 | `CRM-9001::2` | 0.483 | Q1: SLA credit issued, "first real crack in the relationship" |
| 6, 8-10 | `TKT-910xxx` | 0.46 | repeated ticket frustration, no churn language |
| 7 | `CT-99001::2` | 0.464 | Q1 transcript: SLA credit, recovery plan promised |

Every row is real account-level content, in a coherent order, with no
boilerplate and no incident noise.

## Told by search: the whole-corpus case, and its limit

The thematic demo, "truck accident during the Chicago winter storm," no
account filter, is the real case for semantic search: there's no join
path to that question, and no regex a person could write in advance to
catch every way an incident report might describe a storm.

Raw, it fails the same way as the account demo: the top 10 is unrelated
incidents' generic remediation lines plus `IR-9001::3` again. Filtered to
`classification = 'weather_disruption'`, it mostly works: the top 10 is
dominated by tickets naming the January storm and its incident ID
(`INC-2025-00417`) directly, occasionally joined by an incident report
whose remediation genuinely describes a weather-driven dispatch change.

The exact mix isn't stable run to run. `classify()` isn't incremental
(unlike `embed()`, it has no ADR-0023 cache metadata), so a full
reclassification relabels the entire corpus fresh from the LLM every
time, and the same unchanged text can land differently between runs.
One incident-report remediation chunk, "Added a manual weather check to
the dispatch board for this hub before morning departures," has been
classified both `routine_status` and `weather_disruption` across
different reclassification runs in this project's own testing, each
time changing which rows pass the filter. `IR-9001`'s own summary, "a
semi jackknifed on an icy on-ramp... during the Jan 14-16 winter storm,"
hasn't cracked the top 10 in either version, plausibly because that text
reads as `vehicle_or_driver_incident` as easily as `weather_disruption`.
Filtering by category removes irrelevant categories; it doesn't
guarantee the best chunk within a category outranks every other chunk
sharing it, and, as this shows, it doesn't guarantee the same chunk gets
the same category twice.

## Reading it together

The join-based story is exact, exhaustive, and blind to anything not
named explicitly. Raw semantic search asks the right kind of question
and fails for a specific, tested reason. A real, business-scoped
`classify()` taxonomy fixes most of that, with one disclosed gap left
open. All three results came from running real queries against real
data on Snowflake. [Roadmap](roadmap.md) covers what's still missing.
