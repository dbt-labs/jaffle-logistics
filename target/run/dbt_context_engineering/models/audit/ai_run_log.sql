-- back compat for old kwarg name
  
  begin;
    

        insert into sthibeault_test_db.dbt_sthibeault.ai_run_log ("INVOCATION_ID", "MODEL_NAME", "FUNCTION_NAME", "ROW_COUNT", "EST_TOKENS", "EST_COST", "RUN_AT", "COMPLETED")
        (
            select "INVOCATION_ID", "MODEL_NAME", "FUNCTION_NAME", "ROW_COUNT", "EST_TOKENS", "EST_COST", "RUN_AT", "COMPLETED"
            from sthibeault_test_db.dbt_sthibeault.ai_run_log__dbt_tmp
        );
    commit;