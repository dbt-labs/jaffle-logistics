-- conforms_to_schema on legal_docs_classify.content_type: returns every row whose label is
-- outside the jaffle_content_type v1 enum (or null). Zero rows expected. The allowed set is
-- read from the same schema the classify model was given, so the two cannot drift.
-- Gated like the models/context/ai layer: classify output only exists when the AI layer is on.
-- On DuckDB the classify stand-in emits a fixed label, so a pass there proves only that the
-- test compiles and the stand-in is in-taxonomy, not anything about real model output.
{{ config(enabled=var('ai_functions_enabled', false)) }}

{{ dbt_context_engineering.conforms_to_schema(
    relation=ref('legal_docs_classify'),
    column='content_type',
    schema_name='jaffle_content_type',
    schema_version='v1'
) }}
