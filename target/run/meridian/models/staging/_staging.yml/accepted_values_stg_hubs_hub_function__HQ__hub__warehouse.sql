
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        hub_function as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_hubs
    group by hub_function

)

select *
from all_values
where value_field not in (
    'HQ','hub','warehouse'
)



  
  
      
    ) dbt_internal_test