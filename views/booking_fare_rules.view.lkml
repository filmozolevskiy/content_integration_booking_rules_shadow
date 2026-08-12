view: booking_fare_rules {
  sql_table_name: ota.booking_fare_rules ;;

  # -------------------------------------------------------------------
  # Keys (hidden)
  # -------------------------------------------------------------------

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: booking_id {
    type: number
    sql: ${TABLE}.booking_id ;;
    hidden: yes
  }

  # -------------------------------------------------------------------
  # Hidden attributes (available in code, not surfaced in the picker)
  # -------------------------------------------------------------------

  dimension: booking_fare_id {
    type: number
    sql: ${TABLE}.booking_fare_id ;;
    hidden: yes
  }

  dimension: airline_code {
    type: string
    sql: ${TABLE}.airline_code ;;
    hidden: yes
  }

  dimension: flight_id {
    type: string
    sql: ${TABLE}.flight_id ;;
    hidden: yes
  }

  dimension: tour_operator {
    type: string
    sql: ${TABLE}.tour_operator ;;
    hidden: yes
  }

  dimension: is_web_fare {
    type: yesno
    sql: ${TABLE}.web_fare = 1 ;;
    hidden: yes
  }

  # -------------------------------------------------------------------
  # 10. FARE RULES (only visible field)
  # -------------------------------------------------------------------

  dimension: rule {
    type: string
    sql: REGEXP_REPLACE(
           REPLACE(
             REPLACE(
               REGEXP_REPLACE(
                 REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(${TABLE}.rule USING utf8mb4), '&', '&amp;'), '<', '&lt;'), '>', '&gt;'), '"', '&quot;'),
                 _utf8mb4'[ ]*[-‐‑‒–—―−_=]{3,}[ ]*', _utf8mb4'&#10;&#10;'
               ),
               '\r', ''
             ),
             '\n', '&#10;'
           ),
           _utf8mb4'(&#10;){3,}', _utf8mb4'&#10;&#10;'
         ) ;;
    group_label: "10. FARE RULES"
    label: "Fare Rule Text"
    description: "Fare-rule text. Hover the cell to read the full rule (formatted) in a tooltip; the cell shows a short preview."
    html: <span title="{{ value }}" style="cursor: help; border-bottom: 1px dotted #888;">{{ value | replace: '&#10;', ' ' | replace: '&amp;', '&' | replace: '&quot;', '"' | replace: '&lt;', '<' | replace: '&gt;', '>' | truncate: 90 }}</span> ;;
  }

  measure: fare_rule_count {
    type: count_distinct
    sql: ${id} ;;
    hidden: yes
    label: "Fare Rule Rows"
    description: "Distinct booking_fare_rules rows."
  }
}
