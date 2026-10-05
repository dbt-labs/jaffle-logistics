-- classify: a label column instead of a vector
-- In this case, assigning from a named group 
--["account_assessment", "contract_reference", "weather_disruption",
--"vehicle_or_driver_incident", "handling_or_warehouse_error", "routine_status"]

select * --chunk_id, chunk_text, content_type 
from {{ ref('call_transcripts_classify') }}
where chunk_id like 'CT-99001%'
order by chunk_id