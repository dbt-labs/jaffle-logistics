{#-
  Prompt + output schema for this project's own classify() task, 'jaffle_content_type' v1.

  One flat enum (one classify() call, one column, kept simple on purpose): is this content an
  account-level assessment, a contract/legal reference, or an incident, split by its real cause
  (weather / vehicle-or-driver / handling-or-warehouse), or a routine status update with no
  diagnostic content? That's the same weather-vs-handling split docs/comparison.md's own
  CRM-9030 root-cause review already makes, not a category invented to win a demo, and it
  deliberately catches what the structured incidents.type column can't: IR-9001 is typed
  'accident', not 'weather', even though its cause was icy conditions during a named storm.
  classify() reads the text; the structured column only has the event's category.

  See docs/comparison.md and docs/governance.md for what this taxonomy does and doesn't fix,
  including the one honest gap: it doesn't guarantee the single most relevant chunk for a given
  incident outranks other incidents in the same category, only that irrelevant categories get
  excluded.
-#}

{% macro prompt__jaffle_content_type__v1() -%}
{%- raw -%}
Classify the operational text below into exactly one content-type label.

account_assessment: evaluates, summarizes, or discusses the account as a whole, its
relationship, trend, health, or performance over time, rather than one shipment or incident
(e.g. a QBR note, a performance or root-cause review, an internal discussion of the account's
trajectory).
contract_reference: contractual or legal terms, SLA credit language, or a signature/
administrative block.
weather_disruption: describes or was caused by severe weather (a storm, ice, snow), even if the
record's own event category is something else, e.g. an accident whose cause was icy conditions.
vehicle_or_driver_incident: a vehicle- or driver-caused incident not attributable to weather
(e.g. following distance, mechanical failure).
handling_or_warehouse_error: a warehouse or loading-related error (e.g. a mislabeled bin,
improper load securement).
routine_status: a routine shipment status update or confirmation with no specific incident
cause and no account-level assessment.

Text:
{{ input }}
{%- endraw -%}
{%- endmacro %}


{% macro schema__jaffle_content_type__v1() -%}
{%- raw -%}
{
  "type": "object",
  "properties": {
    "content_type": {
      "type": "string",
      "enum": ["account_assessment", "contract_reference", "weather_disruption",
               "vehicle_or_driver_incident", "handling_or_warehouse_error", "routine_status"]
    }
  },
  "required": ["content_type"],
  "additionalProperties": false
}
{%- endraw -%}
{%- endmacro %}
