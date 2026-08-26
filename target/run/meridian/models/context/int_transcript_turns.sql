
  create or replace   view sthibeault_test_db.dbt_sthibeault.int_transcript_turns
  
  
  
  
  as (
    -- Explode each call transcript body into one row per spoken turn — the atomic
-- unit the package's chunk() packs (unit = turn, partition = transcript).
--
-- Body format (see stg_call_transcripts): a bracketed header line
--   [CALL TRANSCRIPT — <Client> (CLI-####) | ... | ref CRM-####]
-- followed by turn lines
--   [Speaker — Org]: text
-- The header has no "]: " sequence, so a simple LIKE filter drops it (and blank
-- lines) and keeps only real turns.
--
-- Snowflake-first (the context layer targets Cortex), with a DuckDB branch so
-- local dev keeps working — mirroring the project's portable.sql ethos. We avoid
-- regex backslash classes entirely (they diverge in string-literal escaping
-- across engines) and use split_part / position instead.
--
-- Grain: one row per (transcript_id, turn_index). turn_id is unique.

with raw_lines as (

    select
        t.transcript_id,
        t.client_id,
        f.value::string as line,
        f.index         as line_no
    from sthibeault_test_db.dbt_sthibeault.stg_call_transcripts t,
         lateral flatten(input => split(t.body, chr(10))) f

),

turns as (
    select
        transcript_id,
        client_id,
        line_no,
        -- speaker name = text between the leading '[' and the ' — ' separator
        substr(split_part(line, ' — ', 1), 2)                     as speaker,
        -- turn text = everything after the "]: " prefix (3 chars: ] : space)
        trim(substr(line, position(']: ' in line) + 3))           as turn_text
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
    transcript_id || '-' || lpad(cast(turn_index as TEXT), 3, '0') as turn_id,
    transcript_id,
    client_id,
    turn_index,
    speaker,
    turn_text
from indexed
  );

