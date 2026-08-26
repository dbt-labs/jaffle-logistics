-- Join AI predictions to the golden fixture (seeds/eval_ticket_triage.csv, the
-- generator's own ground truth) so eval() can score them. Zero AI cost — it only reads
-- pre-computed predictions. Grain: one row per ticket that has both a prediction and a
-- truth row.


select
    t.ticket_id,
    t.category      as predicted_category,
    e.true_category
from sthibeault_test_db.dbt_sthibeault.ticket_triage t
join sthibeault_test_db.dbt_sthibeault.eval_ticket_triage e
    on t.ticket_id = e.ticket_id