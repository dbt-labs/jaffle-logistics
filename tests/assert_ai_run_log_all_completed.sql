-- Governance check on dbt_context_engineering's ai_run_log: log_ai_run inserts a row
-- with completed=false, and complete_ai_run's post-hook flips it to true once the
-- model finishes. A row stuck at completed=false means that invocation's model
-- errored (or was killed) after the pre-hook logged it but before the post-hook
-- confirmed completion. Zero rows expected.
select *
from {{ ref('ai_run_log') }}
where completed = false
