
    
    

select
    note_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.crm_sentiment
where note_id is not null
group by note_id
having count(*) > 1


