
    
    

select
    hr_doc_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_hr_docs
where hr_doc_id is not null
group by hr_doc_id
having count(*) > 1


