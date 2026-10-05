# Roadmap: what's deliberately not built yet

This project covers chunking, embedding, classification, the knowledge
base, and vector search. That's retrieval, plus a real, tested content
filter for one of retrieval's real failure modes. Two things remain
unbuilt. One is hardening that retrieval further. The other is a
separate sentiment/triage classify-and-eval layer on top of it.

## Path A: what's still missing before this is a real RAG pattern

[Comparison](comparison.md) has the real numbers. Plain top-k
cosine-similarity search ranks a six-token trailing fragment ("Reviewed
with dispatch.") and a contract's signature boilerplate above the
account's actual root-cause review. A business-scope `classify()`
taxonomy (`account_assessment` / `weather_disruption` / etc.) fixes the
account-scoped demo cleanly and the thematic demo mostly. Retrieval, as
built here, is the "R" in RAG, now with a real content filter. There's
no "G": `search.sql` returns ranked rows, and nothing synthesizes them
into an answer.

What's still open:

- **The gap inside the classify fix.** Filtering by category excludes
  irrelevant categories. It doesn't guarantee the single most relevant
  chunk within a surviving category outranks every other chunk sharing
  it. `IR-9001`'s own storm summary doesn't surface in the thematic
  demo even filtered to `weather_disruption`, plausibly because the
  same text also reads as `vehicle_or_driver_incident`. Fixing that
  needs reranking over the filtered candidates, not a bigger taxonomy.
- **A taxonomy built without knowing the target queries.** This
  project's categories were chosen for the two queries its demos ask.
  A taxonomy meant to generalize to arbitrary future questions has to
  start from the business's actual information needs, and get
  validated against a held-out query set nobody designed it to answer.
- **A minimum-content floor.** `chunk()`'s soft cap has no lower bound;
  a trailing unit can end up as a nearly-empty chunk (`IR-9001::3` is
  six tokens). `classify()` can label a fragment like that correctly
  and it still occupies a slot in the candidate set as a
  low-information vector. The direct fix is a floor in the `chunk()`
  macro that merges a below-threshold trailing chunk into its
  predecessor, so `chunk_transcripts` and the three document chunkers
  (`chunk_legal_docs` / `chunk_incident_reports` / `chunk_crm_notes`) all inherit it.
- **A generation step.** `search.sql` hands back ranked rows, not an
  answer, even once the above is fixed. Completing the pattern means a
  `generate()`/`ai_complete()`-calling model that takes the top-k
  retrieved rows as context and synthesizes a response, gated behind
  `ai_functions_enabled` and the same `guard_batch`/`log_ai_run` pattern the
  embedding and classification models already use.

None of this is built. This project has retrieval plus a real, working
content filter with one disclosed gap. It doesn't have a RAG pattern
ready to deploy.

## Path B: classify and eval against the ground-truth seeds

Two seeds ship unused by any model:

- `eval_crm_sentiment.csv`, mapping each CRM note (`note_id`) to a
  `true_sentiment` label.
- `eval_ticket_triage.csv`, mapping each support ticket (`ticket_id`) to
  a `true_category` and `true_sentiment` label.

They support a classification-plus-evaluation layer that isn't built: a
model calling `classify()` against CRM notes and support tickets to
predict sentiment and, for tickets, a triage category, checked against
these ground-truth labels for accuracy. That's a different use of
`classify()` than Path A's content-type taxonomy: predicting a label
against a known-correct answer, not filtering search results.

## Why it's out of scope here

Retrieval (chunk, embed, enrich, combine, search) answers a different
question than sentiment/triage classification. Retrieval finds
artifacts relevant to a query; Path A's `classify()` step filters those
artifacts by business category. Sentiment/triage classification labels
every artifact regardless of any query, at a cost that scales with
corpus size, and it's checked against ground truth, a different
governance question (accuracy) than Path A's (does the label set
improve search). Building it in this cut would have added a third
AI-function surface area to get right across four warehouse engines,
without changing the retrieval story this project tells.

## What adding it would take

- A `classify()`-calling model over CRM notes (sentiment) and support
  tickets (sentiment and category), gated behind `ai_functions_enabled` and
  the same `guard_batch`/`log_ai_run` pattern the embedding and Path A
  classification models use, following the same per-project
  prompt/schema pattern (`macros/prompts/`) Path A demonstrates.
- An eval model joining predictions against `eval_crm_sentiment` and
  `eval_ticket_triage` on their IDs, producing an accuracy metric per
  label.
- A governance test asserting eval accuracy doesn't silently regress on
  a rerun, the classification-layer analog to
  `assert_ai_run_log_all_completed`.
- Multi-platform validation: Path A's `classify()` calls are verified
  on Snowflake only; BigQuery and Databricks are wired the same way but
  untested. The DuckDB stand-in pattern is already proven (Path A uses
  it) and just needs applying here.

None of that is built. It's the next worked example this project could
tell, alongside the retrieval one.

## Path C: materialization, sized for a demo, not designed for production

Every model's materialization in this project was picked for this
demo's row counts (dozens to low hundreds of rows per source) and fast
iteration, not evaluated against what a real production corpus would
need. Four specific decisions are unresolved:

- **`classify()` has no incremental delta pattern.** Every `*_classify`
  model is a `table`, and unlike `*_embed` (incremental, with
  dbt_context_engineering's ADR-0023 cache metadata reprocessing only
  new/changed rows), `classify()` reclassifies the whole corpus fresh
  from the LLM on every single build. At this project's scale, with
  dozens to low hundreds of rows per source, that's cheap. At real
  corpus sizes it becomes the dominant cost and runtime
  driver, and nothing here, or in `dbt_context_engineering` itself,
  designs what a `classify()`-side content-hash cache mirroring
  `embed()`'s would look like.
- **The join and union layers undo `embed()`'s incrementality.** Each
  `*_embedded_classified` model and `knowledge_base` itself are
  `table`, so every build fully drops and rewrites them by scanning the
  entire upstream `*_embed` and `*_classify` tables, not just what
  changed. `embed()`'s incremental delta only bounds the embedding
  layer's own cost; the downstream join and five-way union still pay
  for a full corpus rewrite every time. Whether these should become
  incremental themselves, and what an incremental union across five
  independently-refreshed sources would even mean, hasn't been
  designed.
- **The `*_hashed` layer is a view, recomputed on every read.** Each
  source's `content_hash()` computation lives in a `view`
  (`legal_docs_hashed`, `incident_reports_hashed`, and so on), so both
  that source's `*_classify` and `*_embed` models independently re-scan
  the same upstream `*_chunks_meta` table and recompute the same hash.
  Cheap at this scale; real duplicated compute at real scale, and no
  decision has been made about the point at which that view should
  become a table.
- **No indexing story for `knowledge_base` at scale.** `search.sql`
  already notes an opt-in vector-index service exists (`dbt
  run-operation create_vector_index`) as an alternative to brute-force
  cosine similarity. Nothing here decides when a real corpus should
  switch to it, or how a `table`-materialized `knowledge_base` that
  gets fully rewritten every build would coexist with an external index
  that has its own refresh cadence.

None of this is a bug at this project's scale. It's an explicit
disclosure that materialization here followed "what's simplest to
demo," not "what a production-sized version of this pattern would
require," and that gap hasn't been designed yet.
