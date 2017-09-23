SELECT
      user_id,
   client_type,
   gps_latitude,
   gps_longitude,
      SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 1, 10) as creation_date,
      SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 12) as creation_hour
    FROM poc_analytics.STG_USER_ACTIVITIES
 WHERE
  SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 1, 10) = @run_date
