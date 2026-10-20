-- Deliberately isolated Semantic Layer example.
-- Grain: one row per order. This model has no supplier entity, so supplier
-- dimensions cannot be used to group its revenue metrics.
with orders as (

    select
        'order_001' as order_id,
        'customer_001' as customer_id,
        dateadd(day, 0, date_trunc('month', current_date)) as ordered_at,
        125.00 as revenue

    union all

    select
        'order_002' as order_id,
        'customer_002' as customer_id,
        dateadd(day, 1, date_trunc('month', current_date)) as ordered_at,
        80.00 as revenue

    union all

    select
        'order_003' as order_id,
        'customer_001' as customer_id,
        dateadd(day, 2, date_trunc('month', current_date)) as ordered_at,
        210.00 as revenue

)

select * from orders
