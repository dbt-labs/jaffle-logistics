
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        health as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_clients
    group by health

)

select *
from all_values
where value_field not in (
    'healthy','watch','at-risk'
)



  
  
      
    ) dbt_internal_test