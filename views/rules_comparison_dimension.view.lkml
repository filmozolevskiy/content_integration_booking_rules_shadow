view: rules_comparison_dimension {
  # Unnests ota.booking_rules_shadow.rules_comparison into one row per
  # shadow row x pax group (master/slave) x rule dimension. Base table is
  # a rolling ~2-day log (~66k rows), so this inline derived table is cheap
  # and needs no persistence.
  derived_table: {
    sql:
      SELECT
        s.id AS shadow_id,
        g.grp AS pax_group,
        jt.dimension AS dimension,
        (jt.match_flag = 'false') AS is_mismatch,
        jt.mismatch_category AS mismatch_category,
        jt.am_serv AS amadeus_serviceable,
        jt.am_cur AS amadeus_currency,
        jt.am_min AS amadeus_min,
        jt.am_max AS amadeus_max,
        jt.rh_serv AS routehappy_serviceable,
        jt.rh_cur AS routehappy_currency,
        jt.rh_min AS routehappy_min,
        jt.rh_max AS routehappy_max,
        CONCAT(s.id, '-', g.grp, '-', jt.dimension) AS pk
      FROM ota.booking_rules_shadow s
      JOIN (SELECT 'master' grp UNION ALL SELECT 'slave' grp) g
      JOIN JSON_TABLE(
        JSON_EXTRACT(s.rules_comparison, CONCAT('$.', g.grp)),
        '$[*]' COLUMNS (
          dimension VARCHAR(64) PATH '$.dimension',
          match_flag VARCHAR(8) PATH '$.match',
          mismatch_category VARCHAR(64) PATH '$.mismatch_category',
          am_serv VARCHAR(8) PATH '$.amadeus.serviceable',
          am_cur VARCHAR(8) PATH '$.amadeus.penalty.currency',
          am_min VARCHAR(16) PATH '$.amadeus.penalty.minimumAmount',
          am_max VARCHAR(16) PATH '$.amadeus.penalty.maximumAmount',
          rh_serv VARCHAR(8) PATH '$.routehappy.serviceable',
          rh_cur VARCHAR(8) PATH '$.routehappy.penalty.currency',
          rh_min VARCHAR(16) PATH '$.routehappy.penalty.minimumAmount',
          rh_max VARCHAR(16) PATH '$.routehappy.penalty.maximumAmount'
        )
      ) jt ;;
  }

  # -------------------------------------------------------------------
  # Keys (hidden)
  # -------------------------------------------------------------------

  dimension: pk {
    primary_key: yes
    type: string
    sql: ${TABLE}.pk ;;
    hidden: yes
  }

  dimension: shadow_id {
    type: number
    sql: ${TABLE}.shadow_id ;;
    hidden: yes
  }

  # -------------------------------------------------------------------
  # 9. RULE DIMENSION (parsed from rules_comparison)
  # -------------------------------------------------------------------

  dimension: dimension {
    type: string
    sql: ${TABLE}.dimension ;;
    group_label: "9. RULE DIMENSION"
    label: "Rule Dimension"
    description: "The specific fare-rule dimension compared: refund_before_departure, refund_after_departure, exchange_before_departure, exchange_after_departure."
  }

  dimension: pax_group {
    case: {
      when: { sql: ${TABLE}.pax_group = 'master' ;; label: "Primary pax" }
      else: "Secondary pax"
    }
    group_label: "9. RULE DIMENSION"
    label: "Pax"
    description: "Which passenger this comparison element covers (master = primary, slave = secondary)."
  }

  dimension: is_mismatch {
    type: yesno
    sql: ${TABLE}.is_mismatch = 1 ;;
    group_label: "9. RULE DIMENSION"
    label: "Dimension Mismatch"
    description: "Yes when Amadeus and RouteHappy disagreed on this dimension (element match = false)."
  }

  dimension: amadeus_serviceable {
    type: string
    sql: ${TABLE}.amadeus_serviceable ;;
    group_label: "9. RULE DIMENSION"
    label: "Amadeus Serviceable"
    description: "Whether Amadeus returned this rule as serviceable (yes / no)."
  }

  dimension: routehappy_serviceable {
    type: string
    sql: ${TABLE}.routehappy_serviceable ;;
    group_label: "9. RULE DIMENSION"
    label: "RouteHappy Serviceable"
    description: "Whether RouteHappy returned this rule as serviceable (yes / no)."
  }

  dimension: amadeus_penalty {
    type: string
    sql: CASE WHEN ${TABLE}.amadeus_min IS NULL THEN NULL
              ELSE CONCAT(COALESCE(NULLIF(${TABLE}.amadeus_currency, ''), '?'), ' ', ${TABLE}.amadeus_min,
                          CASE WHEN ${TABLE}.amadeus_max <> ${TABLE}.amadeus_min THEN CONCAT(' - ', ${TABLE}.amadeus_max) ELSE '' END)
         END ;;
    group_label: "9. RULE DIMENSION"
    label: "Amadeus Penalty"
    description: "Amadeus penalty as currency + amount (range when min differs from max). Null when Amadeus returned no penalty object."
  }

  dimension: routehappy_penalty {
    type: string
    sql: CASE WHEN ${TABLE}.routehappy_min IS NULL THEN NULL
              ELSE CONCAT(COALESCE(NULLIF(${TABLE}.routehappy_currency, ''), '?'), ' ', ${TABLE}.routehappy_min,
                          CASE WHEN ${TABLE}.routehappy_max <> ${TABLE}.routehappy_min THEN CONCAT(' - ', ${TABLE}.routehappy_max) ELSE '' END)
         END ;;
    group_label: "9. RULE DIMENSION"
    label: "RouteHappy Penalty"
    description: "RouteHappy penalty as currency + amount (range when min differs from max). Null when RouteHappy returned no penalty object."
  }

  dimension: mismatch_category {
    type: string
    sql: ${TABLE}.mismatch_category ;;
    group_label: "9. RULE DIMENSION"
    label: "Mismatch Category"
    description: "Category label the comparator stamped on a mismatch (equals the dimension name); null on a match."
  }

  measure: dimension_comparisons {
    type: count_distinct
    sql: ${pk} ;;
    label: "Dimension Comparisons"
    description: "Distinct per-dimension comparison elements (master + slave)."
    group_label: "9. RULE DIMENSION"
  }

  measure: dimension_mismatches {
    type: count_distinct
    sql: ${pk} ;;
    filters: [is_mismatch: "yes"]
    label: "Dimension Mismatches"
    description: "Distinct comparison elements where Amadeus and RouteHappy disagreed on this dimension."
    group_label: "9. RULE DIMENSION"
  }

  measure: mismatched_shadow_records {
    type: count_distinct
    sql: ${shadow_id} ;;
    filters: [is_mismatch: "yes"]
    label: "Shadow Records Mismatched (this dimension)"
    description: "Distinct shadow rows with a disagreement on the sliced dimension."
    group_label: "9. RULE DIMENSION"
  }
}
