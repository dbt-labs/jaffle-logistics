
  create or replace   view sthibeault_test_db.dbt_sthibeault.int_context_documents
  
  
  
  
  as (
    -- Unify the client-scoped, prose-heavy document artifacts into one common shape so
-- a single split -> chunk -> attach_metadata pipeline covers all of them. Each row
-- is one source document with a resolvable, synthetic citation link.
--
-- Sources: legal_docs, incident_reports, crm_notes. Their partition ids differ
-- (doc_id / report_id / note_id), so we normalize to a single doc_key and stamp a
-- source_type. client_id is carried through so the chunks are account-scopable:
--   - crm_notes / legal_docs carry client_id directly (may be null for some legal
--     doc_types, e.g. a driver-only contract);
--   - incident_reports have no client_id column — they reach the account through the
--     affected shipment (report.shipment_id -> shipment.client_id), so we join it in.
--     A report with no shipment_id stays client_id = null (still searchable, just not
--     account-scoped) — see the CONTEXT_ENGINEERING_PLAN §5 gotcha.
--
-- citation_url is a synthetic, resolvable pointer back to the source artifact:
--   meridian://<source_type>/<id>. attach_metadata carries it onto every chunk, and
-- knowledge_base later promotes it to a first-class provenance column.
--
-- Grain: one row per source document. doc_key is unique across sources (the id
-- prefixes DOC-/RPT-/CRM- are already disjoint).

with legal as (
    select
        doc_id                                          as doc_key,
        'legal_doc'                                     as source_type,
        client_id,
        'meridian://legal_doc/' || doc_id               as citation_url,
        cast(effective_date as timestamp) as artifact_ts,
        body
    from sthibeault_test_db.dbt_sthibeault.stg_legal_docs
),

reports as (
    select
        r.report_id                                     as doc_key,
        'incident_report'                               as source_type,
        s.client_id,
        'meridian://incident_report/' || r.report_id    as citation_url,
        cast(r.filed_at as timestamp)  as artifact_ts,
        r.body
    from sthibeault_test_db.dbt_sthibeault.stg_incident_reports r
    left join sthibeault_test_db.dbt_sthibeault.stg_shipments s
        on r.shipment_id = s.shipment_id
),

crm as (
    select
        note_id                                         as doc_key,
        'crm_note'                                      as source_type,
        client_id,
        'meridian://crm_note/' || note_id               as citation_url,
        cast(call_date as timestamp)   as artifact_ts,
        body
    from sthibeault_test_db.dbt_sthibeault.stg_crm_notes
)

select * from legal
union all
select * from reports
union all
select * from crm
  );

