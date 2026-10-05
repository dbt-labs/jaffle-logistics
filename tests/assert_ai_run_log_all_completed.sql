-- Governance check on dbt_context_engineering's event-sourced ai_run_log: log_ai_run
-- appends a 'started' row, and complete_ai_run appends a SEPARATE 'completed' row for
-- the same invocation once the model finishes (never an UPDATE to the 'started' row,
-- per ADR-0031). A 'started' row with no matching 'completed' row means that
-- invocation's model errored (or was killed) before its post-hook ran. Zero rows
-- expected.
select s.*
from {{ ref('ai_run_log') }} s
left join {{ ref('ai_run_log') }} c
    on c.invocation_id = s.invocation_id
   and c.function_name = s.function_name
   and c.model_name = s.model_name
   and c.event = 'completed'
where s.event = 'started'
  and c.invocation_id is null
