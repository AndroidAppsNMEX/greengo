SELECT
        user_id,
        vehicle_id,
        SUBSTR(REPLACE(REPLACE(booking_date, '.', '-'), ' ', ''), 1, 10) as booking_date,
        SUBSTR(REPLACE(REPLACE(booking_date, '.', '-'), ' ', ''), 12) as booking_hour,
        SUBSTR(REPLACE(REPLACE(end_date, '.', '-'), ' ', ''), 1, 10) as end_date,
        SUBSTR(REPLACE(REPLACE(end_date, '.', '-'), ' ', ''), 12) as end_hour,
        DATETIME(timestamp(concat(SUBSTR(REPLACE(REPLACE(booking_date, '.', '-'), ' ', ''), 1, 10), ' ', SUBSTR(REPLACE(REPLACE(booking_date, '.', '-'), ' ', ''), 12)))) as booking_ts,
        DATETIME(timestamp(concat(SUBSTR(REPLACE(REPLACE(end_date, '.', '-'), ' ', ''), 1, 10), ' ', SUBSTR(REPLACE(REPLACE(end_date, '.', '-'), ' ', ''), 12)))) as end_ts,
        status
      FROM poc_analytics.STG_RENTALS
   WHERE
    SUBSTR(REPLACE(REPLACE(booking_date, '.', '-'), ' ', ''), 1, 10) = @run_date
