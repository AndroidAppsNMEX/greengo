SELECT
   user_id,
   client_type,
   CASE WHEN gps_latitude < 40 THEN gps_longitude ELSE gps_latitude END AS gps_latitude,
   CASE WHEN gps_latitude < 40 THEN gps_latitude ELSE gps_longitude END AS gps_longitude,
   SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 1, 10) as creation_date,
   SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 12) as creation_hour,
   DATETIME(timestamp(concat(SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 1, 10), ' ', SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 12)))) as creation_ts
FROM poc_analytics.STG_USER_ACTIVITIES
WHERE
  SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 1, 10) = @run_date
  AND gps_latitude > 0.0
