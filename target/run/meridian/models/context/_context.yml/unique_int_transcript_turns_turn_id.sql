
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    turn_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.int_transcript_turns
where turn_id is not null
group by turn_id
having count(*) > 1



  
  
      
    ) dbt_internal_test