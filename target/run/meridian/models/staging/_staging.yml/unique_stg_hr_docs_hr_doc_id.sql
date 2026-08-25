
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    hr_doc_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_hr_docs
where hr_doc_id is not null
group by hr_doc_id
having count(*) > 1



  
  
      
    ) dbt_internal_test