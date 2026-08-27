# Jaffle Logistics

Jaffle Logistics is a fictional logistics company, and its data looks like
most companies' data: scattered.

One account's story lives across roughly eight disconnected systems: a CRM,
a support ticketing tool, dispatch notes from the ops floor, incident
reports, legal contracts, Slack threads, and call transcripts. Some of
those systems reference a shipment by a clean, structured ID. Others bury
it in a sentence of free text. Some don't reference a shipment at all;
they reference an incident that itself references a shipment.

Ask a targeted question, "what contributed to poor delivery performance
for the Jaffle Equipment account this year," and the honest answer is
spread across every one of those systems, in a mix of structured columns
and prose nobody indexed for this purpose.

This project is a worked example of a real ceiling in exact-match SQL
patterns, joins and regex, and what it actually takes to get past that
ceiling while staying in dbt:

- **[The problem](the-problem.md)** shows the deterministic baseline: how
  far you can get with joins, a shipment ID regex, and a lot of patience,
  and where that approach runs out of road.
- **[Context engineering](context-engineering.md)** walks through
  [`dbt_context_engineering`](https://github.com/dbt-labs/dbt-context-engineering),
  a package that chunks, embeds, and enriches the same free text in SQL,
  orchestrated by dbt, so it becomes searchable by meaning instead of
  exact match. Enrichment runs alongside embedding, not after it. It's
  a real building block, still short of a finished RAG pattern.
- **[Comparison](comparison.md)** puts both approaches side by side
  against real output, including where plain vector search falls short.
- **[Governance](governance.md)** covers what keeps an AI-function layer
  like this safe to run: cost guards, an audit log, and an incremental
  design that means reruns cost nothing once the content stops changing.
- **[Multi-platform](multi-platform.md)** documents what it took to get
  the same pipeline running correctly on Snowflake, BigQuery, Databricks,
  and DuckDB.
- **[Roadmap](roadmap.md)** is honest about what's deliberately not built
  yet.

Nothing here is production advice for a real logistics company. It's a
project built to show what context engineering in dbt actually looks like,
end to end, against data messy enough to make the exercise worth doing.
