-- Deliberately disconnected supplier dimension for the Semantic Layer example.
-- Grain: one row per supplier. No order or customer entity is declared.
with suppliers as (

    select 'supplier_001' as supplier_id, 'North America' as supplier_region

    union all

    select 'supplier_002' as supplier_id, 'Europe' as supplier_region

    union all

    select 'supplier_003' as supplier_id, 'Asia Pacific' as supplier_region

)

select * from suppliers
