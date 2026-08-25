
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    route_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_routes
where route_id is not null
group by route_id
having count(*) > 1



  
  
      
    ) dbt_internal_test