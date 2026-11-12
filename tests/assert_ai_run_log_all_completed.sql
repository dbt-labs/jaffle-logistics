-- Governance check on dbt_context_engineering's event-sourced ai_run_log: log_ai_run
-- appends a 'started' row, and complete_ai_run appends a SEPARATE 'completed' row for
-- the same invocation once the model finishes (never an UPDATE to the 'started' row,
-- per ADR-0031). A 'started' row with no matching 'completed' row means that
-- invocation's model errored (or was killed) before its post-hook ran. Zero rows
-- expected.
--
-- Matches on node_id (the model unique_id) as well as model_name: without it, one model's
-- 'completed' row could mask another model's failed 'started' row when both log the same
-- function_name and model_name (for example the five classify models, which all log
-- 'ai_classify (built-in)'). node_id is null on rows written outside a model context, so the
-- comparison is null-safe.
select s.*
from {{ ref('ai_run_log') }} s
left join {{ ref('ai_run_log') }} c
    on c.invocation_id = s.invocation_id
   and c.function_name = s.function_name
   and c.model_name = s.model_name
   and (c.node_id = s.node_id or (c.node_id is null and s.node_id is null))
   and c.event = 'completed'
where s.event = 'started'
  and c.invocation_id is null
