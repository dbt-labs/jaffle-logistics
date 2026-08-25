
    
    

select
    wo_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_fleet_work_orders
where wo_id is not null
group by wo_id
having count(*) > 1


