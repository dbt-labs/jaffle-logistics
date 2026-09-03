# Governance: what keeps AI-function spend safe to run

Turning on `ai_functions_enabled` starts real, billed `embed()` and
`classify()` calls. This project uses `dbt_context_engineering`'s
governed pattern to keep that safe: a cost guard before spend happens,
an audit log of what ran, and an incremental design that keeps reruns
cheap.

`ai_functions_enabled` gates two things at once. `dbt_project.yml` keys
`models/context/ai/`'s `+enabled:` config on it directly, a
selection-time gate: dbt skips those models entirely, not just a
documentation convention. The package's own `generate`/`classify`/
`embed`/etc. also refuse to fire unless the same var is `true` for the
target, checked inside the function itself so there's no config value
to forget to route a call through. One flag covers both.

## The cost guard

Every AI-calling model wraps its call with `guard_batch` and
`log_ai_run` as pre-hooks, and `complete_ai_run` as a post-hook.
`guard_batch` checks a batch against `max_batch_rows` and
`max_est_tokens` before any spend happens, and raises if either ceiling
would be exceeded.

Both ceilings stay at the package's defaults (`max_batch_rows: 10000`,
`max_est_tokens: 5000000`), and `cost_per_1k_tokens` is unset. Raising
them is a decision to make explicitly; the guard exists to stop
unapproved spend before it happens, not after.

## The audit log

`log_ai_run` appends a `'started'` row to `ai_run_log` before the AI
call; `complete_ai_run` appends a SEPARATE `'completed'` row for the
same invocation after, rather than updating the `'started'` row in
place (event-sourced, so two independent models writing on different
threads never conflict over the same row). Every run has a record of
what was called, when, and whether it finished, read by checking
whether a `'completed'` row exists for a `'started'` row's keys. A
governance test, `assert_ai_run_log_all_completed`, asserts no
`'started'` row is ever left without a matching `'completed'` row.

`ai_run_log` no longer self-creates on first write. This project wires
`create_ai_run_log_table()` as an `on-run-start` hook in
`dbt_project.yml`, so the table exists, created once and serially,
before any AI-calling model's threads start.

## Retrieval quality is a governance question too

A governed pipeline that returns misleading results has failed, even if
every cost guard passed. Plain top-k cosine similarity over this
project's own knowledge base ranks a six-token trailing fragment ahead
of the account's actual root-cause review (see
[comparison](comparison.md) for the real numbers).

The fix is a `classify()`-based content-type filter:
`account_assessment`, `contract_reference`, `weather_disruption`,
`vehicle_or_driver_incident`, `handling_or_warehouse_error`,
`routine_status`. Each label is a business category, not a proxy for
writing quality, matched to the account's own weather-vs-handling
root-cause split. It fixes the account-scoped demo cleanly and the
thematic demo mostly, with one disclosed gap: filtering by category
excludes irrelevant categories, but doesn't guarantee the single best
chunk within a category outranks every other chunk sharing it.

This taxonomy's categories were picked for the two queries this
project's demos ask. A taxonomy built to generalize to arbitrary future
questions, and validated against queries nobody designed it to answer,
is separate work (see [roadmap](roadmap.md)).

An incremental-delta proof that reruns skip unchanged content, below,
says nothing about whether what got embedded the first time was worth
searching. A `classify()` filter is the same: it has to be checked
against real output, not assumed correct because it's a governed model.

## The incremental-delta proof

Each source's `*_embed` model is incremental, built on the package's
six-column cache metadata (ADR-0023): a chunk or ticket record whose
text hasn't changed is never re-embedded. A rerun of the full AI layer
with no content change reprocessed zero rows on all three cloud
platforms. That's what makes running this layer on a schedule
affordable instead of a recurring full-corpus embedding bill.

## Catching an orphaned embedding after a re-chunk

Each of the five `*_embed` models also carries a `relationships` test
on `chunk_id` back to its own `*_hashed` upstream, the same
`orphan_chunks`/`orphan_embeddings` pattern `dbt_context_engineering`
ships in its own test suite (ADR-0023). If a source's chunking logic
ever changes how its `chunk_id`s are produced, a `chunk_id` an embed
table still holds but the current chunker no longer produces fails
this test loudly, instead of sitting in the knowledge base as a
permanent, undetected gap.

