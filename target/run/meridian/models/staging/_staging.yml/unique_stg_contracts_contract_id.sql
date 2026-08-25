
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    contract_id as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.stg_contracts
where contract_id is not null
group by contract_id
having count(*) > 1



  
  
      
    ) dbt_internal_test