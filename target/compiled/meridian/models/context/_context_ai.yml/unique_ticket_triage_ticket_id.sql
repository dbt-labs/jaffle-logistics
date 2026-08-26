
    
    

select
    ticket_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.ticket_triage
where ticket_id is not null
group by ticket_id
having count(*) > 1


