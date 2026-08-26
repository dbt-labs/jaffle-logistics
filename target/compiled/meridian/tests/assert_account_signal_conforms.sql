-- account_signal_flat.signal (flattened from the extract result) must only hold labels
-- from the account-signal taxonomy.
select signal as _value
from sthibeault_test_db.dbt_sthibeault.account_signal_flat
where signal not in ('churn_risk', 'expansion', 'service_complaint', 'pricing', 'neutral')
or signal is null