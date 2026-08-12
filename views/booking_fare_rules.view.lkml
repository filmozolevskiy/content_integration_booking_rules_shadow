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
    description: "Raw stored fare-rule text (penalty / cancellation / change paragraphs). Display field."
  }

  measure: fare_rule_count {
    type: count_distinct
    sql: ${id} ;;
    hidden: yes
    label: "Fare Rule Rows"
    description: "Distinct booking_fare_rules rows."
  }
}
