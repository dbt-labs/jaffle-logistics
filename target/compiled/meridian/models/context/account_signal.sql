-- Phase 3 — AI enrichment (REAL Cortex cost). DO NOT run until spend is approved.
--
-- extract() the dominant account signal + a grounding quote from each account chunk
-- (transcripts + CRM notes). Returns the raw structured result; account_signal_flat
-- flattens it to typed scalars. Snowflake routes extract through AI_COMPLETE +
-- response_format, so var model_extract (or model_generate) must be set — see the
-- package ADR-0018. Governed guard/log/complete over the pre-filtered input relation.


select
    chunk_id,
    client_id,
    source_type,
    citation_url,
    artifact_ts,
    chunk_text,
    ai_complete(
        model => 'claude-3-5-sonnet',
        prompt => 'You are analyzing an account artifact (a CRM note or a call-transcript segment) for' || chr(10) || 'Meridian Freight & Last-Mile. Identify the single dominant account signal it carries,' || chr(10) || 'and extract the verbatim quote that justifies it.' || chr(10) || '' || chr(10) || 'Signal guidance:' || chr(10) || '- churn_risk: language pointing to non-renewal, cancellation, or a seriously eroding' || chr(10) || '  relationship.' || chr(10) || '- expansion: intent to grow — more volume, new lanes, additional services, upsell.' || chr(10) || '- service_complaint: dissatisfaction with operational service (late/failed deliveries,' || chr(10) || '  mispicks, damage, responsiveness).' || chr(10) || '- pricing: focus on rates, cost, discounts, or contract pricing terms.' || chr(10) || '- neutral: routine content with no strong account signal.' || chr(10) || '' || chr(10) || 'Return only labels defined in the accompanying schema. Do not invent labels. The' || chr(10) || 'evidence MUST be a verbatim, unaltered quote copied from the text below.' || chr(10) || '' || chr(10) || 'Text:' || chr(10) || '' || chunk_text,
        model_parameters => {'max_tokens': 1024},
        response_format => {'type': 'json', 'schema': parse_json($${
  "type": "object",
  "properties": {
    "signal": {
      "type": "string",
      "enum": ["churn_risk", "expansion", "service_complaint", "pricing", "neutral"]
    },
    "evidence": {
      "type": "string",
      "description": "Verbatim quote from the source text supporting the signal (grounding/lineage)."
    }
  },
  "required": ["signal", "evidence"],
  "additionalProperties": false
}$$)}
    ) as signal_raw
from sthibeault_test_db.dbt_sthibeault.account_signal_input