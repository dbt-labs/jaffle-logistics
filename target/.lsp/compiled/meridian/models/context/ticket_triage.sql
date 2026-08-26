-- Phase 3 — AI enrichment (REAL Cortex cost). DO NOT run until spend is approved.
--
-- classify() each support ticket into a handling category (scalar label). Governed
-- pattern: guard_batch pre-hook (circuit breaker) -> AI call in the SELECT ->
-- log_ai_run + complete_ai_run post-hooks. This is a plain table reading a source
-- ref(), so log_ai_run as a post-hook is correct (case 1 in its docstring).
--
-- Guard note: max_batch_rows defaults to 200 (plan §7, "start small for the first
-- guarded sample"). A full ticket run will trip the guard on purpose — sample with a
-- LIMIT or raise max_batch_rows once you've approved the spend.


select
    ticket_id,
    client_id,
    shipment_id,
    cast((ai_classify(
        'You are triaging a customer support ticket for Meridian Freight & Last-Mile, a' || chr(10) || 'regional logistics carrier. Classify the ticket below into exactly one category' || chr(10) || 'describing what the customer is contacting us about.' || chr(10) || '' || chr(10) || 'Category guidance:' || chr(10) || '- delivery_delay: a shipment is running late or missed its promised window, but is' || chr(10) || '  still in transit or eventually arrived.' || chr(10) || '- delivery_failed: a delivery attempt failed or the shipment was not delivered' || chr(10) || '  (returned, lost, refused, undeliverable).' || chr(10) || '- wrong_item: the customer received the wrong item, a mispick, or a damaged/incorrect' || chr(10) || '  package (a fulfillment error, not a timing problem).' || chr(10) || '- general_inquiry: a question, request, or comment not tied to a specific delivery' || chr(10) || '  failure (billing, scheduling, account questions, praise, general status checks).' || chr(10) || '' || chr(10) || 'Return only labels defined in the accompanying schema. Do not invent labels.' || chr(10) || 'Include the verbatim quote from the ticket that justifies the label.' || chr(10) || '' || chr(10) || 'Ticket:' || chr(10) || '' || body,
        array_construct('delivery_delay', 'delivery_failed', 'wrong_item', 'general_inquiry')
    )):labels[0] as TEXT) as category
from sthibeault_test_db.dbt_sthibeault.stg_support_tickets