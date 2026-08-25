
    
    

select
    thread_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_slack_threads
where thread_id is not null
group by thread_id
having count(*) > 1


