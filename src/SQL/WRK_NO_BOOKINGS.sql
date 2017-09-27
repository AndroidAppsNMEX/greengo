CREATE TEMPORARY FUNCTION
  distanceAprox (lat1 FLOAT64,
    lon1 FLOAT64,
    lat2 FLOAT64,
    lon2 FLOAT64)
  RETURNS FLOAT64
  LANGUAGE js AS """

function toRadians(degrees)
{
  var pi = Math.PI;
  return degrees * (pi/180);
}

var R = 6371e3;
var lat1R = toRadians(lat1);
var lat2R = toRadians(lat2);
var difLats = toRadians(lat2-lat1);
var difLons = toRadians(lon2-lon1);

var a = Math.sin(difLats/2) * Math.sin(difLats/2) +
        Math.cos(lat1R) * Math.cos(lat2R) *
        Math.sin(difLons/2) * Math.sin(difLons/2);
var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

var d = R * c;

return d;
""";
SELECT
  user_id,
  client_type,
  vehicle_id,
  gps_latitude,
  gps_longitude,
  creation_date,
  creation_ts,
  v_gps_latitude,
  v_gps_longitude,
  action_ts
FROM (
  SELECT
    user_id,
    client_type,
    vehicle_id,
    gps_latitude,
    gps_longitude,
    creation_date,
    creation_ts,
    v_gps_latitude,
    v_gps_longitude,
    action_ts,
    RANK() OVER (PARTITION BY user_id, creation_ts ORDER BY metersAprox ASC) AS rank_meters
  FROM (
    SELECT
      user_id,
      client_type,
      vehicle_id,
      gps_latitude,
      gps_longitude,
      creation_date,
      creation_ts,
      v_gps_latitude,
      v_gps_longitude,
      action_ts,
      distanceAprox(gps_latitude,
        gps_longitude,
        v_gps_latitude,
        v_gps_longitude) AS metersAprox
    FROM (
      SELECT
        ua.user_id,
        ua.client_type,
        vp.vehicle_id,
        ua.gps_latitude AS gps_latitude,
        ua.gps_longitude AS gps_longitude,
        ua.creation_date AS creation_date,
        ua.creation_ts AS creation_ts,
        CAST(SUBSTR(MAX(CONCAT(CAST(vp.action_ts AS string), CAST(vp.v_gps_latitude AS string))), 20) AS FLOAT64) AS v_gps_latitude,
        CAST(SUBSTR(MAX(CONCAT(CAST(vp.action_ts AS string), CAST(vp.v_gps_longitude AS string))), 20) AS FLOAT64) AS v_gps_longitude,
        MAX(vp.action_ts) AS action_ts
      FROM
        poc_analytics.CLN_USER_ACTIVITIES ua
      INNER JOIN (
        SELECT
          DISTINCT vp.vehicle_id,
          vp.gps_latitude AS v_gps_latitude,
          vp.gps_longitude AS v_gps_longitude,
          vp.action_date,
          vp.action_ts
        FROM
          poc_analytics.CLN_VEHICLE_POSITION vp
        LEFT JOIN
          poc_analytics.CLN_RENTALS r
        ON
          r.vehicle_id = vp.vehicle_id
          AND r.booking_date = vp.action_date
          AND r._PARTITIONTIME = TIMESTAMP(@run_date)
          AND r.booking_ts BETWEEN DATETIME_SUB(vp.action_ts,
            INTERVAL 30 MINUTE)
          AND DATETIME_ADD(vp.action_ts,
            INTERVAL 30 MINUTE)
          AND r.booking_ts >= vp.action_ts
        WHERE
          vp._PARTITIONTIME = TIMESTAMP(@run_date)
          AND (r.status IS NULL
            OR r.status = 'CANCELLED') ) vp
      ON
        ua.creation_ts BETWEEN DATETIME_SUB(vp.action_ts,
          INTERVAL 30 MINUTE)
        AND DATETIME_ADD(vp.action_ts,
          INTERVAL 30 MINUTE)
      LEFT JOIN
        poc_analytics.CLN_RENTALS r
      ON
        r.booking_date = ua.creation_date
        AND r.user_id = ua.user_id
        AND r.booking_ts BETWEEN DATETIME_SUB(ua.creation_ts,
          INTERVAL 1 MINUTE)
        AND DATETIME_ADD(ua.creation_ts,
          INTERVAL 1 MINUTE)
        AND r.booking_ts >= ua.creation_ts
      WHERE
        ua._PARTITIONTIME = TIMESTAMP(@run_date)
        AND vp.action_ts IS NOT NULL
        AND (r.user_id IS NOT NULL
          OR r.status = 'CANCELLED')
      GROUP BY
        ua.user_id,
        ua.client_type,
        vp.vehicle_id,
        ua.gps_latitude,
        ua.gps_longitude,
        ua.creation_date,
        ua.creation_ts) x ) y ) z
WHERE
  rank_meters <= 3;
