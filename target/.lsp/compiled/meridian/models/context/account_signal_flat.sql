-- Flatten the extract() result into typed scalar columns (portable across engines via
-- field()). signal is conformance-tested against the schema enum; evidence is
-- grounded-tested (must be a verbatim substring of chunk_text). Zero additional AI
-- cost — this only reads columns already produced by account_signal.


select
    chunk_id,
    client_id,
    source_type,
    citation_url,
    artifact_ts,
    chunk_text,
    cast((signal_raw):signal as TEXT)   as signal,
    cast((signal_raw):evidence as TEXT) as evidence
from sthibeault_test_db.dbt_sthibeault.account_signal