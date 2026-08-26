-- Explode each call transcript body into one row per spoken turn — the atomic
-- unit the package's chunk() packs (unit = turn, partition = transcript).
--
-- Body format: a bracketed header line
--   [CALL TRANSCRIPT — <Client> (CLI-####) | ... | ref CRM-####]
-- followed by turn lines
--   [Speaker — Org]: text
-- The header has no "]: " sequence, so a simple LIKE filter drops it (and blank
-- lines) and keeps only real turns.
--
-- Portable across all four engines this package targets (duckdb for local dev;
-- Snowflake, BigQuery, Databricks for real cloud AI-function cost). Array-flattening
-- syntax diverges the most: duckdb's unnest()/range(), Snowflake's
-- lateral flatten(), BigQuery's unnest()...with offset, and Databricks'
-- lateral view posexplode(). We avoid regex backslash classes entirely (they
-- diverge in string-literal escaping across engines) and use split_part /
-- position instead, both portable dbt-core macros.
--
-- Grain: one row per (transcript_id, turn_index). turn_id is unique.

with raw_lines as (
{% if target.type == 'duckdb' %}
    select
        transcript_id,
        client_id,
        unnest(string_split(body, chr(10)))                    as line,
        unnest(range(1, len(string_split(body, chr(10))) + 1)) as line_no
    from {{ ref('stg_call_transcripts') }}
{% elif target.type == 'bigquery' %}
    select
        t.transcript_id,
        t.client_id,
        line,
        line_offset as line_no
    from {{ ref('stg_call_transcripts') }} t,
         unnest(split(t.body, chr(10))) as line with offset as line_offset
{% elif target.type == 'databricks' %}
    select
        t.transcript_id,
        t.client_id,
        line,
        line_no
    from {{ ref('stg_call_transcripts') }} t
    lateral view posexplode(split(t.body, chr(10))) exploded_lines as line_no, line
{% else %}
    select
        t.transcript_id,
        t.client_id,
        f.value::string as line,
        f.index         as line_no
    from {{ ref('stg_call_transcripts') }} t,
         lateral flatten(input => split(t.body, chr(10))) f
{% endif %}
),

turns as (
    select
        transcript_id,
        client_id,
        line_no,
        -- speaker name = text between the leading '[' and the ' — ' separator
        substr({{ dbt.split_part('line', "' — '", 1) }}, 2)       as speaker,
        -- turn text = everything after the "]: " prefix (3 chars: ] : space)
        trim(substr(line, {{ dbt.position("']: '", 'line') }} + 3)) as turn_text
    from raw_lines
    -- keep only turn lines: start with '[', contain a "]: " delimiter
    where line like '[%]: %'
),

indexed as (
    select
        transcript_id,
        client_id,
        row_number() over (partition by transcript_id order by line_no) - 1 as turn_index,
        speaker,
        turn_text
    from turns
    where length(turn_text) > 0
)

select
    transcript_id || '-' || lpad(cast(turn_index as {{ dbt.type_string() }}), 3, '0') as turn_id,
    transcript_id,
    client_id,
    turn_index,
    speaker,
    turn_text
from indexed
