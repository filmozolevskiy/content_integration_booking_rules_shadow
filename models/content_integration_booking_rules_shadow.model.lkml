connection: "ota"

include: "/views/**/*.view.lkml"

# Successful booking-contestant attempts (last window) joined to their
# Amadeus-vs-RouteHappy fare-rules shadow comparison.
explore: bookability_contestant_attempts {
  label: "Booking Rules Shadow"
  description: "Successful booking attempts joined to the booking_rules_shadow comparison (Amadeus vs RouteHappy refund / exchange rules). Grain: one row per attempt-to-shadow match."

  join: booking_rules_shadow {
    type: inner
    relationship: many_to_many
    # Why (2026-08-11, FM): booking_rules_shadow is not unique per
    # (search_id, package_id) (29,806 rows / 29,753 pairs) and many attempts
    # share one search + package, so the join fans out both ways. The
    # count_distinct measures keyed on each view's PK keep counts
    # symmetric-safe under this many_to_many.
    sql_on: ${booking_rules_shadow.search_id} = ${bookability_contestant_attempts.search_hash}
        AND ${booking_rules_shadow.package_id} = ${bookability_contestant_attempts.package_hash} ;;
  }

  # Bound the 24M-row base table. Defaults reproduce the source query
  # (successful attempts) over a rolling 30-day window; the analyst can
  # widen or narrow them.
  always_filter: {
    filters: [
      bookability_contestant_attempts.date_created_date: "30 days",
      bookability_contestant_attempts.status: "1"
    ]
  }
}
