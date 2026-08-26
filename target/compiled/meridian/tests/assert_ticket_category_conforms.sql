-- The classify() output must only hold labels from the ticket-triage taxonomy — the
-- allowed set is resolved from the same schema macro the wrapper used, so it can never
-- drift into a hand-copied list. Fails loudly if the model invents a label.
-- Deterministic, zero AI cost.
select category as _value
from sthibeault_test_db.dbt_sthibeault.ticket_triage
where category not in ('delivery_delay', 'delivery_failed', 'wrong_item', 'general_inquiry')
or category is null