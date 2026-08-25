-- Small adapter-aware helpers so the models run on both Snowflake (the
-- jaffle-mcp-demo profile) and DuckDB. Regex and date-format functions differ by
-- warehouse; these switch on target.type.

-- First regex match in a column (or NULL/'' if none). Dispatch notes embed at
-- most one shipment ID, so first-match is sufficient.
{% macro regex_first(col, pattern) %}
    {%- if target.type == 'duckdb' -%}
        regexp_extract({{ col }}, '{{ pattern }}')
    {%- else -%}
        regexp_substr({{ col }}, '{{ pattern }}')
    {%- endif -%}
{% endmacro %}

-- Boolean: does the column contain a match for the pattern?
{% macro has_match(col, pattern) %}
    {%- if target.type == 'duckdb' -%}
        regexp_matches({{ col }}, '{{ pattern }}')
    {%- else -%}
        regexp_substr({{ col }}, '{{ pattern }}') is not null
    {%- endif -%}
{% endmacro %}

-- Format a date/timestamp as 'YYYY-MM'.
{% macro month_key(col) %}
    {%- if target.type == 'duckdb' -%}
        strftime({{ col }}, '%Y-%m')
    {%- else -%}
        to_char({{ col }}, 'YYYY-MM')
    {%- endif -%}
{% endmacro %}
