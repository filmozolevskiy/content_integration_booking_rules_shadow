view: bookability_contestant_attempts {
  sql_table_name: ota.bookability_contestant_attempts ;;

  # -------------------------------------------------------------------
  # Keys (hidden)
  # -------------------------------------------------------------------

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: search_hash {
    type: string
    sql: ${TABLE}.search_hash ;;
    hidden: yes
  }

  dimension: package_hash {
    type: string
    sql: ${TABLE}.package_hash ;;
    hidden: yes
  }

  # -------------------------------------------------------------------
  # 1. DATE
  # -------------------------------------------------------------------

  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.date_created ;;
    group_label: "1. DATE"
    label: "Attempt Created"
    description: "When the booking-contestant attempt ran (ota.bookability_contestant_attempts.date_created). Primary time filter; the column is indexed."
  }

  # -------------------------------------------------------------------
  # 2. ATTEMPT INFO
  # -------------------------------------------------------------------

  dimension: booking_id {
    type: number
    sql: ${TABLE}.booking_id ;;
    group_label: "2. ATTEMPT INFO"
    label: "Booking ID"
    description: "FK to ota.bookings.id. Set when the attempt finalized into a booking; NULL otherwise."
  }

  dimension: gds {
    type: string
    sql: ${TABLE}.gds ;;
    group_label: "2. ATTEMPT INFO"
    label: "GDS / Content Source"
    description: "GDS or content source used for the attempt. Values are lowercase, e.g. 'sabre', 'dida'."
  }

  dimension: validating_carrier {
    type: string
    sql: ${TABLE}.validating_carrier ;;
    group_label: "2. ATTEMPT INFO"
    label: "Validating Carrier"
    description: "Validating airline (2-letter IATA code)."
  }

  dimension: fare_type {
    type: string
    sql: ${TABLE}.fare_type ;;
    group_label: "2. ATTEMPT INFO"
    label: "Fare Type"
    description: "Fare type of the attempt, e.g. 'private' or 'published'."
    suggestions: ["private", "published"]
  }

  dimension: office_id {
    type: string
    sql: ${TABLE}.office_id ;;
    group_label: "2. ATTEMPT INFO"
    label: "Office / PCC"
    description: "GDS office / PCC used for the attempt."
  }

  # -------------------------------------------------------------------
  # 3. STATUS & ERRORS
  # -------------------------------------------------------------------

  dimension: status {
    type: number
    sql: ${TABLE}.status ;;
    group_label: "3. STATUS & ERRORS"
    label: "Status (raw)"
    description: "Final status of the attempt: 1 = success, 0 = failure."
  }

  dimension: status_label {
    case: {
      when: { sql: ${status} = 1 ;; label: "Success" }
      when: { sql: ${status} = 0 ;; label: "Failure" }
      else: "Other"
    }
    group_label: "3. STATUS & ERRORS"
    label: "Status"
    description: "Human-readable attempt status derived from the raw 0/1 status column."
  }

  dimension: is_success {
    type: yesno
    sql: ${status} = 1 ;;
    group_label: "3. STATUS & ERRORS"
    label: "Is Success"
    description: "Yes when the attempt succeeded (status = 1)."
  }

  dimension: error {
    type: string
    sql: ${TABLE}.error ;;
    group_label: "3. STATUS & ERRORS"
    label: "Error (normalized)"
    description: "Normalized error label reported by the GDS, e.g. 'flight_not_available_other', 'payment_error'."
  }

  dimension: exception {
    type: string
    sql: ${TABLE}.exception ;;
    group_label: "3. STATUS & ERRORS"
    label: "Exception"
    description: "Internal code exception message for the attempt."
  }

  dimension: gds_error_message {
    type: string
    sql: ${TABLE}.gds_error_message ;;
    group_label: "3. STATUS & ERRORS"
    label: "GDS Error Message"
    description: "Raw error text from the GDS."
  }

  # -------------------------------------------------------------------
  # 4. COUNTS
  # -------------------------------------------------------------------

  measure: attempts_count {
    type: count_distinct
    sql: ${id} ;;
    label: "Attempts"
    description: "Distinct booking-contestant attempts. count_distinct on the PK so it stays correct through the fan-out join to booking_rules_shadow."
    group_label: "4. COUNTS"
  }

  measure: successful_attempts {
    type: count_distinct
    sql: ${id} ;;
    filters: [is_success: "yes"]
    label: "Successful Attempts"
    description: "Distinct attempts with status = 1."
    group_label: "4. COUNTS"
  }

  measure: distinct_bookings {
    type: count_distinct
    sql: ${booking_id} ;;
    label: "Distinct Bookings"
    description: "Distinct non-null booking IDs among the matched attempts."
    group_label: "4. COUNTS"
  }
}
