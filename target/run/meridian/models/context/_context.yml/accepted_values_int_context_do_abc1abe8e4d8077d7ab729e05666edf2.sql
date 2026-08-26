
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        source_type as value_field,
        count(*) as n_records

    from sthibeault_test_db.dbt_sthibeault.int_context_documents
    group by source_type

)

select *
from all_values
where value_field not in (
    'legal_doc','incident_report','crm_note'
)



  
  
      
    ) dbt_internal_test