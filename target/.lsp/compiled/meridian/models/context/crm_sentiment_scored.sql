-- Join CRM-sentiment predictions to the golden fixture
-- (seeds/eval_crm_sentiment.csv — the sentiment each note was authored with). Zero AI
-- cost. Grain: one row per note with both a prediction and a truth row.


select
    c.note_id,
    c.sentiment     as predicted_sentiment,
    e.true_sentiment
from sthibeault_test_db.dbt_sthibeault.crm_sentiment c
join sthibeault_test_db.dbt_sthibeault.eval_crm_sentiment e
    on c.note_id = e.note_id