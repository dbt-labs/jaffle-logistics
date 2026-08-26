
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select citation_url
from sthibeault_test_db.dbt_sthibeault.chunks_with_meta
where citation_url is null



  
  
      
    ) dbt_internal_test