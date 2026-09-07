# jaffle logistics

A fictional logistics company's data, scattered across roughly eight
disconnected systems (CRM, support tickets, dispatch notes, incident
reports, legal contracts, Slack, call transcripts), used as a worked
example of where exact-match SQL (joins, regex) runs out of road, and
what it takes to get past that ceiling while staying in dbt: chunking,
embedding, and classifying free text into a governed, searchable
knowledge base via
[`dbt_context_engineering`](https://github.com/dbt-labs/dbt-context-engineering).
The full story, with real query output, lives in [`docs/`](docs/index.md).

## How to use this project

### Prerequisites

- dbt Core 1.8 or higher
- An adapter for whichever warehouse you want to target: `dbt-duckdb`, `dbt-snowflake`, `dbt-bigquery`, or `dbt-databricks`


### Get running locally with DuckDB

DuckDB is the fastest path to seeing the project run, and the only target where the AI layer can never bill, since DuckDB has no `embed()` or `classify()` implementation.

1. Install dependencies.

   ```bash
   dbt deps
   ```

2. Add a profile named `jaffle-logistics` to `~/.dbt/profiles.yml`.

   ```yaml
   jaffle-logistics:
     target: duckdb
     outputs:
       duckdb:
         type: duckdb
         path: jaffle_logistics.duckdb
         threads: 4
   ```

3. Build the project.

   ```bash
   dbt build
   ```

   This seeds the source CSVs and builds the staging, intermediate, and marts models. The AI layer under `models/context/ai/` is skipped. `dbt_project.yml` sets `ai_functions_enabled: false` by default, so a plain `dbt build` never triggers a billed `embed()` or `classify()` call.

### Running the AI layer

Setting `ai_functions_enabled: true` builds the models under `models/context/ai/` instead of skipping them. Point your profile at Snowflake, BigQuery, or Databricks for that to mean real work: `embed()` and `classify()` calls that hit a real model endpoint and bill.

```bash
dbt build --vars '{"ai_functions_enabled": true}'
```

The same flag also builds these models on DuckDB, but each one detects the DuckDB target and substitutes a hardcoded placeholder, either a zero vector or a fixed label, instead of calling `embed()`/`classify()`. The build succeeds and produces real rows, just with fake, structurally-compatible values instead of real AI output. So "DuckDB is the only target where the AI layer can never bill" describes this substitution, rather than a build failure or a skipped model.

See [governance](docs/governance.md) for what the cost guards and audit log around this call do.

## Lineage

The context-engineering pipeline, colored by phase (source, staging,
up-to-meta, up-to-knowledge-base, knowledge base):

![Context engineering pipeline lineage](docs/assets/dag-context.png)

## Project structure

```
.
├── models/
│   ├── staging/
│   ├── intermediate/
│   ├── marts/
│   └── context/
│       └── ai/
├── seeds/
├── analyses/
├── macros/
├── tests/
└── docs/
```

| Path | Contents |
|---|---|
| `models/staging/` | One model per source system, cleans and casts raw seed data |
| `models/intermediate/` | Cross-source joins (shipment touchpoints, SLA rollups) |
| `models/marts/` | Client/driver/hub dimensions and fact tables |
| `models/context/` | The context-engineering pipeline: chunk/reshape and hash, one independent chain per source (legal docs, incident reports, CRM notes, call transcripts, support tickets) |
| `models/context/ai/` | `embed()`/`classify()` calls per source, plus `knowledge_base` (unions all five) and `search` — gated behind `ai_functions_enabled`, real billed cloud calls |
| `seeds/` | Source data as CSVs, one per system above, plus two unused eval seeds for a classify-and-eval layer that isn't built yet |
| `analyses/` | The deterministic (join-only) and narrative demo queries |
| `macros/` | Portable cross-warehouse helpers and AI prompt definitions |
| `tests/` | Singular tests, including an AI-run-log completeness check |
| `docs/` | The full write-up, built as an mkdocs-material site |

Four adapters are supported: DuckDB (local, free), Snowflake, BigQuery, and
Databricks. Only DuckDB has no `embed()`/`classify()` implementation, so it's
the only target where the AI layer can never bill.

## Docs site

This project has models to illustrate a specific story. The full story, including
real search results, is in `docs/` and builds as an
mkdocs-material site (`mkdocs serve` / `mkdocs build`, `mkdocs.yml` at repo
root):

- [The problem](docs/the-problem.md) — the join-and-regex baseline, and where it breaks
- [Context engineering](docs/context-engineering.md) — chunk, embed, enrich, combine, search
- [Comparison](docs/comparison.md) — join-based vs. semantic retrieval, against real output
- [Governance](docs/governance.md) — cost guards, audit log, incremental reruns
- [Multi-platform](docs/multi-platform.md) — cross-engine SQL portability fixes
- [Roadmap](docs/roadmap.md) — what's deliberately not built yet

## Known issues

External issues that block or limit part of this project. Tracked upstream; not fixable here.

- **[dbt-core#16128](https://github.com/dbt-labs/dbt-core/issues/16128)**: on the Fusion engine (`dbt-fusion`), the DuckDB adapter fails to load a seed owned by an installed package. Symptom is an `IO Error: No files found` against a doubled path (`.../dbt_packages/<pkg>/dbt_packages/<pkg>/seeds/<file>.csv`). Confirmed Fusion-engine-only: `dbt-core` 1.12 loads the same seed fine on every adapter, and Fusion loads it fine on Snowflake, BigQuery, and Databricks; only the DuckDB adapter under Fusion fails. In this project it only affects `dbt_context_engineering`'s `embedding_canary_baseline` seed, which only builds when `ai_functions_enabled: true`. A plain `dbt build`/`dbtf build` is unaffected, since that seed stays disabled by default. Resolves automatically once dbt-fusion ships a fix; no project-side action needed.

## Support & maintenance

This project is provided as-is, without SLAs. It's a worked example, not a maintained product, and maintenance is best-effort.

To report an issue or request a change, open a GitHub issue or discussion on this repo.