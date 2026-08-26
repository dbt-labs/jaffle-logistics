-- One row per Slack thread. linked_ids is a space-separated free-text list of
-- typed IDs; downstream models extract shipment IDs from it and from body.
select
    thread_id,
    channel,
    participants,
    cast(started_at as timestamp)   as started_at,
    linked_ids,
    -- body is stored with embedded newlines escaped to '~~NL~~' (portable seed-
    -- loading workaround: some engines reject a quoted CSV field containing a
    -- real newline unless configured otherwise); restore them here.
    replace(body, '~~NL~~', chr(10)) as body
from {{ ref('slack_threads') }}
