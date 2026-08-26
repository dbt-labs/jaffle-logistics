
    
    

select
    sentence_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.split_context_docs
where sentence_id is not null
group by sentence_id
having count(*) > 1


