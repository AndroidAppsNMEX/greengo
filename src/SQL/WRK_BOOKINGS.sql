select 
ua.user_id, 
ua.client_type, 
CAST(SUBSTR(MAX(concat(cast(ua.creation_ts as string), cast(ua.gps_latitude as string))), 20) AS FLOAT64) AS gps_latitude, 
CAST(SUBSTR(MAX(concat(cast(ua.creation_ts as string), cast(ua.gps_longitude as string))), 20) AS FLOAT64) AS gps_longitude, 
MAX(ua.creation_date) AS creation_date,
MAX(ua.creation_ts) as creation_ts, 
CAST(SUBSTR(MAX(concat(cast(vp.action_ts as string), cast(vp.gps_latitude as string))), 20) AS FLOAT64) as v_gps_latitude, 
CAST(SUBSTR(MAX(concat(cast(vp.action_ts as string), cast(vp.gps_longitude as string))), 20) AS FLOAT64) as v_gps_longitude, 
max(vp.action_ts) as action_ts,
r.vehicle_id, 
r.booking_ts, 
r.end_ts,
r.status
from poc_analytics.CLN_RENTALS r 
inner join poc_analytics.CLN_USER_ACTIVITIES ua
  on ua.user_id = r.user_id 
  and ua.creation_date = r.booking_date
  and r.booking_ts
      between DATETIME_SUB(ua.creation_ts, INTERVAL 1 MINUTE) 
        and DATETIME_ADD(ua.creation_ts, INTERVAL 1 MINUTE) 
  and r.booking_ts >= ua.creation_ts
left join poc_analytics.CLN_VEHICLE_POSITION vp
  on r.vehicle_id = vp.vehicle_id
  and r.booking_date = vp.action_date
  and vp._PARTITIONTIME = TIMESTAMP(@run_date)
  and r.booking_ts
      between DATETIME_SUB(vp.action_ts, INTERVAL 30 MINUTE) 
        and DATETIME_ADD(vp.action_ts, INTERVAL 30 MINUTE) 
  and r.booking_ts >= vp.action_ts
where                                                         
ua._PARTITIONTIME = TIMESTAMP(@run_date)
and r._PARTITIONTIME = TIMESTAMP(@run_date)
and vp.action_ts is not null
group by
  ua.user_id, 
  ua.client_type, 
  r.vehicle_id, 
  r.booking_ts, 
  r.end_ts,
  r.status;
