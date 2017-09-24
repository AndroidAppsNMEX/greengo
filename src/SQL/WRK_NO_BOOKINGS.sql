select 
ua.user_id, 
ua.client_type, 
vp.vehicle_id,
ua.gps_latitude AS gps_latitude, 
ua.gps_longitude AS gps_longitude, 
ua.creation_date AS creation_date,
ua.creation_ts as creation_ts, 
CAST(SUBSTR(MAX(concat(cast(vp.action_ts as string), cast(vp.v_gps_latitude as string))), 20) AS FLOAT64) as v_gps_latitude, 
CAST(SUBSTR(MAX(concat(cast(vp.action_ts as string), cast(vp.v_gps_longitude as string))), 20) AS FLOAT64) as v_gps_longitude, 
max(vp.action_ts) as action_ts
from poc_analytics.CLN_USER_ACTIVITIES ua
inner join 
  (   select 
   distinct 
   	vp.vehicle_id, 
   	vp.gps_latitude as v_gps_latitude, 
   	vp.gps_longitude as v_gps_longitude, 
   	vp.action_date,
   	vp.action_ts
   from poc_analytics.CLN_VEHICLE_POSITION vp
   left join poc_analytics.CLN_RENTALS r
   	on r.vehicle_id = vp.vehicle_id
   	and r.booking_date = vp.action_date
   	and r._PARTITIONTIME = TIMESTAMP(@run_date)
   	and r.booking_ts
      between DATETIME_SUB(vp.action_ts, INTERVAL 30 MINUTE) 
      	and DATETIME_ADD(vp.action_ts, INTERVAL 30 MINUTE) 
   	and r.booking_ts >= vp.action_ts
   where                                                         
   	vp._PARTITIONTIME = TIMESTAMP(@run_date)
   	and (r.status is null or r.status = 'CANCELLED')
  ) vp ON
	 ua.creation_ts
      between DATETIME_SUB(vp.action_ts, INTERVAL 30 MINUTE) 
        and DATETIME_ADD(vp.action_ts, INTERVAL 30 MINUTE)
LEFT JOIN poc_analytics.CLN_RENTALS r ON 
	r.booking_date = ua.creation_date
	and r.user_id = ua.user_id
	and r.booking_ts
      between DATETIME_SUB(ua.creation_ts, INTERVAL 1 MINUTE) 
        and DATETIME_ADD(ua.creation_ts, INTERVAL 1 MINUTE) 
  and r.booking_ts >= ua.creation_ts
where                                                         
ua._PARTITIONTIME = TIMESTAMP(@run_date)
and vp.action_ts is not null
and (r.user_id is not null or r.status = 'CANCELLED')
group by
  ua.user_id, 
  ua.client_type, 
  vp.vehicle_id,
  ua.gps_latitude, 
  ua.gps_longitude, 
  ua.creation_date,
  ua.creation_ts; 
