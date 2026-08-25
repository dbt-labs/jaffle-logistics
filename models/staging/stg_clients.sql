-- One row per client.
select
    client_id,
    name                as client_name,
    tier,
    line_of_business,
    region,
    health
from {{ ref('clients') }}
