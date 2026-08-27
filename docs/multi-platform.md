# Multi-platform: writing SQL that actually runs everywhere

This project builds and passes on four engines: Snowflake, BigQuery,
Databricks, and DuckDB for local dev. Getting there wasn't free; it
surfaced several latent cross-engine bugs, each one a small worked
example of what "portable dbt SQL" actually has to account for.

## `date_trunc` argument order

Not every warehouse takes `date_trunc`'s arguments in the same order, so
this project doesn't call any warehouse's native `date_trunc` directly.
Every truncation goes through dbt's cross-database macro,
`{{ dbt.date_trunc('month', 'created_at') }}`, which resolves to the
correct argument order per adapter.

## Non-portable casts

A few cast patterns that work on one engine silently fail or behave
differently on another: `double`, `try_cast`, and `varchar` aren't
uniformly available or uniformly named across Snowflake, BigQuery,
Databricks, and DuckDB. These got replaced with portable equivalents
during the multi-platform build-out.

## Snowflake-only array-flatten syntax

An array-flattening pattern that's idiomatic on Snowflake isn't
recognized elsewhere. It was rewritten to a form every target engine
understands, rather than branching the SQL per adapter.

## `split_part` / `position` portability

String-splitting and substring-position functions are another spot where
naming and argument order drift across engines. Both got normalized to
portable calls rather than adapter-specific branches.

## The BigQuery seed-loading newline problem

BigQuery's CSV loader rejects a quoted field that contains an embedded
newline unless the load job is configured for it, and this project's seed
data legitimately needs multi-line text: CRM note bodies, incident report
narratives, call transcript text. Reconfiguring the loader per seed
wasn't the path taken; the workaround lives in the seed data and the
staging layer instead.

Embedded newlines in seed CSVs are escaped to a placeholder token,
`~~NL~~`, at seed time. Every staging model that reads one of those
columns restores the real newline before the text goes anywhere else in
the DAG:

```sql
-- body is stored with embedded newlines escaped to '~~NL~~' (portable seed-
-- loading workaround: some engines reject a quoted CSV field containing a
-- real newline unless configured otherwise); restore them here.
replace(body, '~~NL~~', chr(10)) as body
```

That pattern repeats across every staging model touching free text:
`stg_crm_notes`, `stg_support_tickets`, `stg_slack_threads`,
`stg_call_transcripts`, `stg_incident_reports`, `stg_legal_docs`,
`stg_dispatch_notes`, `stg_fleet_work_orders`, and `stg_hr_docs`. It's
the same fix applied consistently rather than solved once and forgotten
in the other eight places it was needed.

## BigQuery's schema-autodetection edge case

BigQuery's autodetection infers a seed column's type from its sample
values, and for `sla_ontime_pct` it inferred `INT64` from the values it
sampled, then rejected the literal `"97.0"` text actually present in the
CSV. The fix is a per-target contract override in `dbt_project.yml`,
explicit on BigQuery, harmless everywhere else because the other three
engines infer the column correctly on their own:

```yaml
+column_types:
  sla_ontime_pct: "{{ 'float64' if target.type == 'bigquery' else 'float' }}"
```

## Required vars that only fail at parse time

A subtler portability trap: `dbt_context_engineering`'s `embedding_canary`
monitor renders its Jinja during dbt's parse phase, before its own
`enabled: false` config ever gets a chance to filter it out of the build.
That means `embedding_model` and, on Snowflake specifically,
`embedding_canary_vector_dimension` (`VECTOR`'s dimension is part of the
type itself) have to be set correctly in `dbt_project.yml` for the
project to parse at all on Snowflake, even when nothing in that layer is
actually selected to run. Missing either one doesn't fail loudly at the
model that needs it; it fails the entire `dbt build` at parse time,
before model selection is even evaluated.
