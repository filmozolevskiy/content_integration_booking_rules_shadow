view: booking_rules_shadow {
  sql_table_name: ota.booking_rules_shadow ;;

  # -------------------------------------------------------------------
  # Keys (hidden)
  # -------------------------------------------------------------------

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: search_id {
    type: string
    sql: ${TABLE}.search_id ;;
    hidden: yes
  }

  dimension: package_id {
    type: string
    sql: ${TABLE}.package_id ;;
    hidden: yes
  }

  # -------------------------------------------------------------------
  # 1. DATE
  # -------------------------------------------------------------------

  dimension_group: time_added {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.time_added ;;
    group_label: "1. DATE"
    label: "Shadow Compared"
    description: "When the shadow comparison was recorded (ota.booking_rules_shadow.time_added)."
  }

  # -------------------------------------------------------------------
  # 5. SHADOW COMPARISON
  # -------------------------------------------------------------------

  dimension: log_id {
    type: string
    sql: ${TABLE}.log_id ;;
    group_label: "5. SHADOW COMPARISON"
    label: "Log ID"
    description: "Debug-log document id for the shadow comparison. Used to build the debug-logs deep link."
  }

  dimension: matches {
    type: yesno
    sql: ${TABLE}.matches = 1 ;;
    group_label: "5. SHADOW COMPARISON"
    label: "Rules Match"
    description: "Yes when Amadeus and RouteHappy agreed on all rule dimensions (matches = 1). Unknown when the comparison did not run (NULL)."
  }

  dimension: is_refund_mismatch {
    type: yesno
    sql: ${TABLE}.refund_mismatch > 0 ;;
    group_label: "5. SHADOW COMPARISON"
    label: "Refund Mismatch"
    description: "Yes when the refund rules disagreed between Amadeus and RouteHappy."
  }

  dimension: is_exchange_mismatch {
    type: yesno
    sql: ${TABLE}.exchange_mismatch > 0 ;;
    group_label: "5. SHADOW COMPARISON"
    label: "Exchange Mismatch"
    description: "Yes when the exchange rules disagreed between Amadeus and RouteHappy."
  }

  dimension: is_any_mismatch {
    type: yesno
    sql: ${TABLE}.refund_mismatch > 0 OR ${TABLE}.exchange_mismatch > 0 ;;
    group_label: "5. SHADOW COMPARISON"
    label: "Any Mismatch"
    description: "Yes when either refund or exchange rules disagreed. Mirrors the commented (refund_mismatch > 0 OR exchange_mismatch > 0) filter in the source query."
  }

  dimension: mismatch_type {
    case: {
      when: { sql: ${TABLE}.refund_mismatch > 0 AND ${TABLE}.exchange_mismatch > 0 ;; label: "Refund + Exchange" }
      when: { sql: ${TABLE}.refund_mismatch > 0 ;; label: "Refund only" }
      when: { sql: ${TABLE}.exchange_mismatch > 0 ;; label: "Exchange only" }
      when: { sql: ${TABLE}.matches = 1 ;; label: "Match" }
      else: "Not compared"
    }
    group_label: "5. SHADOW COMPARISON"
    label: "Mismatch Type"
    description: "Which rule family disagreed: refund only, exchange only, both, a clean match, or not compared (NULL flags)."
  }

  dimension: debug_log_link {
    type: string
    sql: CONCAT('https://reservations.voyagesalacarte.ca/debug-logs/log-group/', ${search_id}, '#', ${log_id}) ;;
    group_label: "5. SHADOW COMPARISON"
    label: "Debug Logs Link"
    description: "Deep link to the debug log group for this search + log id."
    html: <a href="{{ value }}" target="_blank">View debug logs</a> ;;
  }

  # -------------------------------------------------------------------
  # 6. RULE PAYLOADS (display-only JSON)
  # -------------------------------------------------------------------

  dimension: rules_comparison {
    type: string
    sql: ${TABLE}.rules_comparison ;;
    group_label: "6. RULE PAYLOADS"
    label: "Rules Comparison (JSON)"
    description: "Per-dimension comparison JSON: master / slave arrays where each element carries dimension, match, mismatch_category, and the amadeus vs routehappy penalty. Display field; the JSON is not parsed in LookML."
  }

  dimension: rules {
    type: string
    sql: ${TABLE}.rules ;;
    group_label: "6. RULE PAYLOADS"
    label: "Rules - Amadeus (JSON)"
    description: "Raw fare-rules payload from Amadeus (the current source). Display field."
  }

  dimension: rules_routehappy {
    type: string
    sql: ${TABLE}.rules_routehappy ;;
    group_label: "6. RULE PAYLOADS"
    label: "Rules - RouteHappy (JSON)"
    description: "Raw fare-rules payload from RouteHappy (the candidate source). Display field."
  }

  # -------------------------------------------------------------------
  # 7. SHADOW METRICS
  # -------------------------------------------------------------------

  measure: shadow_count {
    type: count_distinct
    sql: ${id} ;;
    label: "Shadow Records"
    description: "Distinct booking_rules_shadow comparison rows. count_distinct on the PK keeps it correct through the fan-out join."
    group_label: "7. SHADOW METRICS"
  }

  measure: matched_count {
    type: count_distinct
    sql: ${id} ;;
    filters: [matches: "yes"]
    label: "Matched Records"
    description: "Distinct shadow rows where Amadeus and RouteHappy agreed."
    group_label: "7. SHADOW METRICS"
  }

  measure: mismatched_count {
    type: count_distinct
    sql: ${id} ;;
    filters: [is_any_mismatch: "yes"]
    label: "Mismatched Records"
    description: "Distinct shadow rows with a refund or exchange disagreement."
    group_label: "7. SHADOW METRICS"
  }

  measure: refund_mismatch_count {
    type: count_distinct
    sql: ${id} ;;
    filters: [is_refund_mismatch: "yes"]
    label: "Refund Mismatches"
    description: "Distinct shadow rows where the refund rules disagreed."
    group_label: "7. SHADOW METRICS"
  }

  measure: exchange_mismatch_count {
    type: count_distinct
    sql: ${id} ;;
    filters: [is_exchange_mismatch: "yes"]
    label: "Exchange Mismatches"
    description: "Distinct shadow rows where the exchange rules disagreed."
    group_label: "7. SHADOW METRICS"
  }

  measure: mismatch_rate {
    type: number
    sql: 1.0 * ${mismatched_count} / NULLIF(${shadow_count}, 0) ;;
    value_format: "0.0%"
    label: "Mismatch Rate"
    description: "Mismatched shadow rows divided by all shadow rows in the current filters."
    group_label: "7. SHADOW METRICS"
  }
}
