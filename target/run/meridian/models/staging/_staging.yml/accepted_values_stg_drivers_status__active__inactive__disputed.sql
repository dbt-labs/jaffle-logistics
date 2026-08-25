
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        status as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_drivers
    group by status

)

select *
from all_values
where value_field not in (
    'active','inactive','disputed'
)



  
  
      
    ) dbt_internal_test