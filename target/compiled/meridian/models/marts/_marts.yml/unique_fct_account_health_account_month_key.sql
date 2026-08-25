
    
    

select
    account_month_key as unique_field,
    count(*) as n_records

from sthibeault_test_db.dbt_sthibeault.fct_account_health
where account_month_key is not null
group by account_month_key
having count(*) > 1


