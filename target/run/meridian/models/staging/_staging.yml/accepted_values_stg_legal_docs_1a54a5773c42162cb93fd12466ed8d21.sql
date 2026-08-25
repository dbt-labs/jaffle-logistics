
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        doc_type as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.stg_legal_docs
    group by doc_type

)

select *
from all_values
where value_field not in (
    'MSA','SLA_addendum','driver_agreement'
)



  
  
      
    ) dbt_internal_test