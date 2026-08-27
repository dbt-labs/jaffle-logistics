-- Phase 4: one account-scoped knowledge base over five independently
-- hashed/classified/embedded sources, in the package's common shape
-- (source_type, source_id, account_key, text, embedding, ts, citation_url,
-- classification). This is what makes "everything about Jaffle Equipment
-- across systems" a single vector search. Pure portable SQL (union + common-
-- shape casts); zero AI-function cost itself, but it reads all five
-- embedding/classification models, so build those first.
--
-- This is knowledge_base's actual documented job (dbt_context_engineering
-- ADR-0006, ADR-0014): union many pre-embedded, independently-maintained
-- sources into one conformed shape. Each source keeps its own native
-- chunk/hash/classify/embed path end to end, so source_type here is a real,
-- per-source literal, not a passthrough of an already-unified column; each
-- represents genuinely different upstream delivery.
--
-- All sources MUST share one embedding model (var embedding_model): a
-- corpus embedded by one model can't be searched by another (version_guard
-- enforces this upstream, per-source, and is "a real constraint on the
-- caller" per ADR-0006, not something this union can check for you).
--
-- classification carries each row's classify() label (content_type:
-- account_assessment / contract_reference / weather_disruption /
-- vehicle_or_driver_incident / handling_or_warehouse_error /
-- routine_status). This is a worked example, so one shared taxonomy and
-- prompt across all five sources is deliberate; a real system with
-- genuinely different content per source would diverge the prompt per
-- source instead. It's the fix for what plain cosine similarity gets wrong
-- here: see docs/comparison.md and docs/governance.md for the real,
-- measured before/after.
{{ config(materialized='table') }}

{{ dbt_context_engineering.knowledge_base([
    {'relation': ref('legal_docs_embedded_classified'), 'source_type': 'Legal Document',
     'source_id': 'chunk_id', 'account_key': 'client_id',
     'text': 'chunk_text', 'embedding': 'embedding', 'timestamp': 'artifact_ts',
     'citation_url': 'citation_url', 'classification': 'classification'},
    {'relation': ref('incident_reports_embedded_classified'), 'source_type': 'Incident Report',
     'source_id': 'chunk_id', 'account_key': 'client_id',
     'text': 'chunk_text', 'embedding': 'embedding', 'timestamp': 'artifact_ts',
     'citation_url': 'citation_url', 'classification': 'classification'},
    {'relation': ref('crm_notes_embedded_classified'), 'source_type': 'CRM Notes',
     'source_id': 'chunk_id', 'account_key': 'client_id',
     'text': 'chunk_text', 'embedding': 'embedding', 'timestamp': 'artifact_ts',
     'citation_url': 'citation_url', 'classification': 'classification'},
    {'relation': ref('call_transcripts_embedded_classified'), 'source_type': 'Call Transcript',
     'source_id': 'chunk_id', 'account_key': 'client_id',
     'text': 'chunk_text', 'embedding': 'embedding', 'timestamp': 'artifact_ts',
     'citation_url': 'citation_url', 'classification': 'classification'},
    {'relation': ref('support_tickets_embedded_classified'), 'source_type': 'Support Ticket',
     'source_id': 'chunk_id', 'account_key': 'client_id',
     'text': 'chunk_text', 'embedding': 'embedding', 'timestamp': 'artifact_ts',
     'citation_url': 'citation_url', 'classification': 'classification'}
]) }}
