

with _rows as (
    select
        evidence         as _evidence,
        chunk_text  as _source
    from sthibeault_test_db.dbt_sthibeault.account_signal_flat
)
select _evidence, _source
from _rows
where
    (_evidence is null or length(trim(_evidence)) = 0)
    or
    not (
        position(lower(regexp_replace(trim(_evidence), '\\s+', ' ')) in lower(regexp_replace(trim(_source), '\\s+', ' '))) > 0
    )

