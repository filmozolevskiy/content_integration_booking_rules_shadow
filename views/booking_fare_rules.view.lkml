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
    sql: ${TABLE}.rule ;;
    group_label: "10. FARE RULES"
    label: "Fare Rule Text"
    description: "Fare-rule text. Click the cell to open the full rule in a drill overlay."
    drill_fields: [booking_fare_rules.booking_id, booking_fare_rules.airline_code, booking_fare_rules.rule_full]
    html: <a href="#drillmenu" target="_self">{{ value | truncate: 80 }}</a> ;;
  }

  dimension: rule_full {
    type: string
    hidden: yes
    label: "Fare Rule (full)"
    description: "Full fare-rule text, reformatted for the drill overlay: HTML-escaped, divider runs and newlines converted to <br> so line breaks survive the overlay's whitespace collapsing."
    sql: REGEXP_REPLACE(
           REPLACE(
             REPLACE(
               REGEXP_REPLACE(
                 REPLACE(REPLACE(REPLACE(CONVERT(${TABLE}.rule USING utf8mb4), '&', '&amp;'), '<', '&lt;'), '>', '&gt;'),
                 _utf8mb4'[ ]*-{3,}[ ]*', _utf8mb4'\n\n'
               ),
               '\r', ''
             ),
             '\n', '<br>'
           ),
           _utf8mb4'(<br>){3,}', _utf8mb4'<br><br>'
         ) ;;
    html: <div style="font-family: monospace; line-height: 1.5; max-width: 680px;">{{ value }}</div> ;;
  }

  measure: fare_rule_count {
    type: count_distinct
    sql: ${id} ;;
    hidden: yes
    label: "Fare Rule Rows"
    description: "Distinct booking_fare_rules rows."
  }
}
