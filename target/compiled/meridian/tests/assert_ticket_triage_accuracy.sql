-- Gate on triage quality: fail the build if overall accuracy drops below the
-- threshold, so a prompt/model change that regresses classification is caught in CI.
-- Deterministic, zero AI cost (reads the pre-computed eval metrics). Tune the
-- threshold as the prompt matures.


select metric, label, value
from sthibeault_test_db.dbt_sthibeault.ticket_triage_eval
where metric = 'accuracy'
  and value < 0.7