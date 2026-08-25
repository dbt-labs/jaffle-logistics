
    
    

select
    doc_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_legal_docs
where doc_id is not null
group by doc_id
having count(*) > 1


