
    
    

with child as (
    select crm_note_id as from_field
    from sthibeault_test_db.dbt_sthibeault.stg_call_transcripts
    where crm_note_id is not null
),

parent as (
    select note_id as to_field
    from sthibeault_test_db.dbt_sthibeault.stg_crm_notes
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


