-- Gate on CRM-sentiment quality: fail if overall accuracy drops below threshold.


select metric, label, value
from sthibeault_test_db.dbt_sthibeault.crm_sentiment_eval
where metric = 'accuracy'
  and value < 0.6