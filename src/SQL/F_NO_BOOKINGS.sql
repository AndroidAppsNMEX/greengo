select 
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
walking_duration,
walking_distance,
walking_duration_range,
walking_distance_range
from (  
  select 
    n_bookings.user_id,
	n_bookings.client_type,
	n_bookings.vehicle_id,
	case when n_bookings.gps_latitude < 47 then n_bookings.gps_longitude else n_bookings.gps_latitude end as gps_latitude,
	case when n_bookings.gps_latitude < 47 then n_bookings.gps_latitude else n_bookings.gps_longitude end as gps_longitude,
	n_bookings.creation_date,
	n_bookings.creation_ts,
	n_bookings.v_gps_latitude,
	n_bookings.v_gps_longitude,
	n_bookings.action_ts,
    distance.seconds as walking_duration, 
    distance.meter as walking_distance,
    case when seconds < 300 then '< 5 Minutes'
      when seconds >= 300 and seconds < 600 then '5 - 10 Minutes'
      when seconds >= 600 and seconds < 900 then '10 - 15 Minutes'
      when seconds >= 900 and seconds < 1200 then '15 - 20 Minutes'
      when seconds >= 1200 and seconds < 1800 then '20 - 30 Minutes'
      else '> 30 Minutes'
    end as walking_duration_range,
	case when seconds < 300 then 1
      when seconds >= 300 and seconds < 600 then 2
      when seconds >= 600 and seconds < 900 then 3
      when seconds >= 900 and seconds < 1200 then 4
      when seconds >= 1200 and seconds < 1800 then 5
      else 6
    end as walking_duration_range_sort,
    case when meter < 100 then '< 100 Meters'
      when meter >= 100 and meter < 300 then '100 - 300 Meters'
      when meter >= 300 and meter < 600 then '300 - 600 Meters'
      when meter >= 600 and meter < 1000 then '600 - 1K Meters'
      when meter >= 1000 and meter < 1500 then '1K - 1.5K Meters'
      else '> 1.5K Meters'
    end as walking_distance_range,
	case when meter < 100 then 1
      when meter >= 100 and meter < 300 then 2
      when meter >= 300 and meter < 600 then 3
      when meter >= 600 and meter < 1000 then 4
      when meter >= 1000 and meter < 1500 then 5
      else 6
    end as walking_distance_range_sort,
	rank() over (partition by n_bookings.user_id, n_bookings.creation_ts order by distance.meter asc) as top_closest_cars
  from poc_analytics.WRK_NO_BOOKINGS n_bookings
  inner join poc_analytics.WRK_NO_BOOKINGS_DISTANCE distance 
    on n_bookings.user_id = distance.user_id
    and n_bookings.vehicle_id = distance.vehicle_id
    and n_bookings.creation_ts = distance.creation_ts
  where
    n_bookings._PARTITIONTIME = TIMESTAMP(@run_date)
    and distance._PARTITIONTIME = TIMESTAMP(@run_date)
	and n_bookings.user_id <> 117360734
	and (distance.meter > 0
	or distance.seconds > 0))
where
	top_closest_cars <= 3;
