
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    doc_key as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.int_context_documents
where doc_key is not null
group by doc_key
having count(*) > 1



  
  
      
    ) dbt_internal_test