-- Score ticket-triage predictions vs. ground truth: accuracy + per-label
-- precision/recall (metric, label, value rows). Deterministic, zero AI cost.
-- prompt_version stamps each row so metrics can be snapshotted across prompt/model
-- changes. A test in _context_ai.yml thresholds the accuracy row to gate regressions.


with _base as (
    select
        predicted_category as pred,
        true_category   as expected
    from sthibeault_test_db.dbt_sthibeault.ticket_triage_scored
),
_overall as (
    select
        'accuracy' as metric,
        '__overall__' as label,
        cast(sum(case when pred = expected then 1 else 0 end) as float)
            / nullif(count(*), 0) as value
    from _base
),
_preds as (
    select
        pred as label,
        count(*) as pred_pos,
        sum(case when pred = expected then 1 else 0 end) as tp
    from _base
    group by pred
),
_acts as (
    select expected as label, count(*) as act_pos
    from _base
    group by expected
),
_per_label as (
    select
        coalesce(p.label, a.label) as label,
        coalesce(p.tp, 0)          as tp,
        coalesce(p.pred_pos, 0)    as pred_pos,
        coalesce(a.act_pos, 0)     as act_pos
    from _preds p
    full outer join _acts a on p.label = a.label
),
_precision as (
    select 'precision' as metric, label,
           cast(tp as float) / nullif(pred_pos, 0) as value
    from _per_label
),
_recall as (
    select 'recall' as metric, label,
           cast(tp as float) / nullif(act_pos, 0) as value
    from _per_label
),
_metrics as (
    select * from _overall
    union all select * from _precision
    union all select * from _recall
)
select
    'meridian_ticket_triage/v1' as prompt_version,
    metric,
    label,
    value
from _metrics