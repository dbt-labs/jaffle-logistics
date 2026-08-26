
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    chunk_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.chunk_docs
where chunk_id is not null
group by chunk_id
having count(*) > 1



  
  
      
    ) dbt_internal_test