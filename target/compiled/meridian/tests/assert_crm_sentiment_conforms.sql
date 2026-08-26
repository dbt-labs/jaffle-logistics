-- crm_sentiment.sentiment must only hold labels from the CRM-sentiment taxonomy.
select sentiment as _value
from sthibeault_test_db.dbt_sthibeault.crm_sentiment
where sentiment not in ('positive', 'neutral', 'concerned')
or sentiment is null