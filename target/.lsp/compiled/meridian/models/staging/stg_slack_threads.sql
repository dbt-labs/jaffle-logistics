-- One row per Slack thread. linked_ids is a space-separated free-text list of
-- typed IDs; downstream models extract shipment IDs from it and from body.
select
    thread_id,
    channel,
    participants,
    cast(started_at as timestamp)   as started_at,
    linked_ids,
    body
from sthibeault_test_db.dbt_sthibeault.slack_threads