select 
  bookings.*,
  distance.seconds as walking_duration, 
  distance.meters as walking_distance,
  case when seconds < 300 then '< 5 Minutes'
    when seconds >= 300 and seconds < 600 then '5 - 10 Minutes'
    when seconds >= 600 and seconds < 900 then '10 - 15 Minutes'
    when seconds >= 900 and seconds < 1200 then '15 - 20 Minutes'
    when seconds >= 1200 and seconds < 1800 then '20 - 30 Minutes'
    else '> 30 Minutes'
  end as walking_duration_range,
  case when meters < 100 then '< 100 Meters'
    when meters >= 100 and meters < 300 then '100 - 300 Meters'
    when meters >= 300 and meters < 600 then '300 - 600 Meters'
    when meters >= 600 and meters < 1000 then '600 - 1K Meters'
    when meters >= 1000 and meters < 1500 then '1K - 1.5K Meters'
    else '> 1.5K Meters'
  end as walking_distance_range
from poc_analytics.WRK_BOOKINGS bookings
inner join poc_analytics.WRK_BOOKINGS_DISTANCE distance 
  on bookings.user_id = distance.user_id
  and bookings.vehicle_id = distance.vehicle_id
  and FORMAT_DATETIME('%FT%T', bookings.booking_ts) = distance.booking_ts
where
  bookings._PARTITIONTIME = TIMESTAMP(@run_date)
  and distance._PARTITIONTIME = TIMESTAMP(@run_date)
  and status <> 'CANCELLED'
