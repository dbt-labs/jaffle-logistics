
    
    

select
    chunk_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.transcript_chunks_meta
where chunk_id is not null
group by chunk_id
having count(*) > 1


