-- Phase 3 — AI enrichment (REAL Cortex cost). DO NOT run until spend is approved.
--
-- classify() each CRM/QBR note into its authored sentiment (scalar label). Scored in
-- Phase 5 against seeds/eval_crm_sentiment.csv. Governed guard/log/complete pattern;
-- plain table over a source ref() so log_ai_run is a post-hook (case 1).


select
    note_id,
    client_id,
    cast((ai_classify(
        'You are assessing the tone of an internal account note written by a Meridian account' || chr(10) || 'owner after a client call, QBR, or account-planning session. Classify the overall' || chr(10) || 'sentiment of the note toward the state of the client relationship into exactly one' || chr(10) || 'label.' || chr(10) || '' || chr(10) || 'Sentiment guidance:' || chr(10) || '- positive: the relationship is healthy — satisfaction, growth, expansion, praise.' || chr(10) || '- neutral: routine or mixed — steady state, no strong signal either way.' || chr(10) || '- concerned: risk language — dissatisfaction, escalations, churn/renewal risk,' || chr(10) || '  eroding trust, or unresolved service problems.' || chr(10) || '' || chr(10) || 'Return only labels defined in the accompanying schema. Do not invent labels.' || chr(10) || 'Include the verbatim quote from the note that best justifies the label.' || chr(10) || '' || chr(10) || 'Account note:' || chr(10) || '' || body,
        array_construct('positive', 'neutral', 'concerned')
    )):labels[0] as TEXT) as sentiment
from sthibeault_test_db.dbt_sthibeault.stg_crm_notes