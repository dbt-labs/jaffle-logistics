
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        line_of_business as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_clients
    group by line_of_business

)

select *
from all_values
where value_field not in (
    'last-mile','LTL','warehousing'
)



  
  
      
    ) dbt_internal_test