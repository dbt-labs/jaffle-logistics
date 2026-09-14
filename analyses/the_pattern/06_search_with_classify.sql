-- same query, filtered on "classification = 'account_assessment'"
select source_id, score, text
from {{ ref('search') }}
where demo = 'jaffle_equipment_performance_issues_classified'
order by score desc