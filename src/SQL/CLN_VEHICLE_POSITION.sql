SELECT
      vehicle_id,
      SUBSTR(REPLACE(REPLACE(action_date, '.', '-'), ' ', ''), 1, 10) as action_date,
      SUBSTR(REPLACE(REPLACE(action_date, '.', '-'), ' ', ''), 12) as action_hour,
      DATETIME(timestamp(concat(SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 1, 10), ' ', SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 12)))) as creation_ts,
      CASE WHEN gps_latitude < 40 THEN gps_longitude ELSE gps_latitude END AS gps_latitude,
      CASE WHEN gps_latitude < 40 THEN gps_latitude ELSE gps_longitude END AS gps_longitude,
      battery
    FROM poc_analytics.STG_VEHICLE_POSITION
 WHERE
  SUBSTR(REPLACE(REPLACE(action_date, '.', '-'), ' ', ''), 1, 10) = @run_date
  AND gps_latitude > 0.0
