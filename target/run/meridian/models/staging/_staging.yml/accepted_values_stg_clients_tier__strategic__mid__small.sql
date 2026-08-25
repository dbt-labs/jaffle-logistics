
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        tier as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_clients
    group by tier

)

select *
from all_values
where value_field not in (
    'strategic','mid','small'
)



  
  
      
    ) dbt_internal_test