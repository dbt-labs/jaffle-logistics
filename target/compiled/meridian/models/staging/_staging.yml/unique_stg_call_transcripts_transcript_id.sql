
    
    

select
    transcript_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_call_transcripts
where transcript_id is not null
group by transcript_id
having count(*) > 1


