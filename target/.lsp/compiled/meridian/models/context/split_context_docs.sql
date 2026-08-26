-- Layer-1 splitter (deterministic, zero AI cost): turn each document body into one
-- row per sentence, so chunk() can pack sentences into token-bounded chunks. The
-- boundary rule is naive ([.!?]) and identical on every engine — good enough for a
-- teaching corpus; a production corpus would split with a real tokenizer upstream.
-- Output columns: sentence_id, document_id (= doc_key), sentence_index, sentence_text.


with _ce_sentences as (
        select
        doc_key as document_id,
        f.index + 1 as sentence_index,
        trim(f.value::string) as sentence_text
    from sthibeault_test_db.dbt_sthibeault.int_context_documents,
         lateral flatten(input => split(
             regexp_replace(
                 regexp_replace(body, '^[.!?]+', ''),
                 '([.!?]+)', '\\1~~CE_SENT~~'
             ), '~~CE_SENT~~'
         )) f
    )
    select
        cast(document_id as TEXT) || '-' || cast(sentence_index as TEXT) as sentence_id,
        document_id,
        sentence_index,
        sentence_text
    from _ce_sentences
    where sentence_text is not null and trim(sentence_text) <> ''
    order by document_id, sentence_index