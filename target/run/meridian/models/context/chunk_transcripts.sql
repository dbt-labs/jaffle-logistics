
  
    

create or replace transient table sthibeault_test_db.dbt_sthibeault.chunk_transcripts
    
    
    
    as (-- Pack transcript turns into token-bounded chunks (package chunk(), pure window
-- SQL, zero AI cost). A chunk never spans a transcript and never splits a turn;
-- each turn's id is carried into source_rows for lineage. speaker prefixes each
-- turn as "speaker: text" inside chunk_text so the embedding/LLM sees who spoke.


with _ce_units as (
    select
        turn_id        as _unit_id,
        turn_index     as _unit_order,
        transcript_id as _partition_key,
        speaker || ': ' || turn_text        as _unit_text,
        ceil(length(speaker || ': ' || turn_text) / 4.0) as _unit_tokens
    from sthibeault_test_db.dbt_sthibeault.int_transcript_turns
),

_ce_binned as (
    select
        _unit_id, _unit_order, _partition_key, _unit_text,
        coalesce(
            sum(_unit_tokens) over (
                partition by _partition_key
                order by _unit_order
                rows between unbounded preceding and 1 preceding
            ), 0
        ) as _cum_before
    from _ce_units
),

_ce_primary as (
    select
        _unit_id, _unit_order, _partition_key, _unit_text, _cum_before,
        cast(floor(_cum_before / 512) as bigint) as _primary_k
    from _ce_binned
),

_ce_exploded as (
    -- every unit belongs to its own chunk ...
    select _unit_id, _unit_order, _partition_key, _unit_text, _primary_k as _raw_k
    from _ce_primary
),

_ce_assigned as (
    select
        _unit_id, _unit_order, _partition_key, _unit_text,
        dense_rank() over (partition by _partition_key order by _raw_k) as _chunk_seq
    from _ce_exploded
),

_ce_chunks as (
    select
        _partition_key,
        _chunk_seq,
        array_agg(_unit_id) within group (order by _unit_order)                    as source_rows,
        listagg(_unit_text, '
') within group (order by _unit_order) as chunk_text,
        count(*)                                                             as n_source_rows
    from _ce_assigned
    group by _partition_key, _chunk_seq
)

select
    cast(_partition_key as TEXT) || '::' || cast(_chunk_seq as TEXT) as chunk_id,
    _partition_key as partition_key,
    _chunk_seq     as chunk_seq,
    source_rows,
    chunk_text,
    n_source_rows,
    ceil(length(chunk_text) / 4.0) as token_estimate
from _ce_chunks
order by _partition_key, _chunk_seq
    )
;


  