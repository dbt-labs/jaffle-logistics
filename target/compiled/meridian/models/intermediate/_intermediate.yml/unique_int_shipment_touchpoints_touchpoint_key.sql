
    
    

select
    touchpoint_key as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.int_shipment_touchpoints
where touchpoint_key is not null
group by touchpoint_key
having count(*) > 1


