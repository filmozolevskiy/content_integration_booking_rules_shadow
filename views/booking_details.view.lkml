view: booking_details {
  sql_table_name: ota.booking_details ;;

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
  # 8. PACKAGE UPGRADE
  # -------------------------------------------------------------------

  dimension: is_upgraded_package {
    type: yesno
    sql: ${TABLE}.is_upgraded_package = 1 ;;
    group_label: "8. PACKAGE UPGRADE"
    label: "Is Upgraded Package"
    description: "Yes when the booking was upgraded to a higher fare family / package (ota.booking_details.is_upgraded_package = 1)."
  }

  dimension: upgrade_type {
    type: string
    sql: ${TABLE}.upgrade_type ;;
    group_label: "8. PACKAGE UPGRADE"
    label: "Upgrade Type"
    description: "Type of package upgrade, e.g. 'fare_family'. Null when not upgraded."
  }

  dimension: upgrade_source_page {
    type: string
    sql: ${TABLE}.upgrade_source_page ;;
    group_label: "8. PACKAGE UPGRADE"
    label: "Upgrade Source Page"
    description: "Page where the upgrade was chosen, e.g. 'search' or 'checkout'. Null when not upgraded."
  }

  measure: upgraded_bookings {
    type: count_distinct
    sql: ${booking_id} ;;
    filters: [is_upgraded_package: "yes"]
    label: "Upgraded Bookings"
    description: "Distinct bookings flagged as upgraded package."
    group_label: "8. PACKAGE UPGRADE"
  }
}
