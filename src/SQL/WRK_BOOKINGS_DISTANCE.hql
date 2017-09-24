set hive.exec.dynamic.partition.mode=nonstrict;
set hive.mapred.mode=nonstrict;

DROP TABLE IF EXISTS greengo.wrk_booking_tmp;
CREATE EXTERNAL TABLE IF NOT EXISTS greengo.wrk_bookings_tmp
STORED AS AVRO
LOCATION 'gs://poc-data-greengo/greengo/wrk_bookings'
TBLPROPERTIES ('avro.schema.url'='gs://poc-data-greengo/schema_bookings.avsc');

MSCK REPAIR TABLE greengo.wrk_bookings_tmp;

drop table if exists greengo.wrk_bookings_distance;
CREATE EXTERNAL TABLE IF NOT EXISTS greengo.wrk_bookings_distance(
  `user_id` int COMMENT '',
  `vehicle_id` int COMMENT '',
  `booking_ts` string,
  `gps_latitude` float COMMENT '',
  `gps_longitude` float COMMENT '',
  `v_gps_latitude` float COMMENT '',
  `v_gps_longitude` float COMMENT '',
  `seconds` int COMMENT '',
  `meters` int COMMENT '')
PARTITIONED BY (
booking_date string
)
STORED AS AVRO
LOCATION 'gs://poc-data-greengo/greengo/wrk_bookings_distance';

ADD FILE hdfs:///tmp/distance.py;
INSERT OVERWRITE TABLE  greengo.wrk_bookings_distance PARTITION(booking_date)
select
    user_id,
vehicle_id,
booking_ts,
gps_latitude,
gps_longitude,
v_gps_latitude,
v_gps_longitude,
seconds,
meters,
'$RUN_DATE' AS booking_date
from (
    from (
        select
            user_id,
            vehicle_id,
        booking_ts,
            gps_latitude,
            gps_longitude,
            v_gps_latitude,
            v_gps_longitude
        from greengo.wrk_bookings_tmp
        ) tmp1
    select transform (
      user_id,
      vehicle_id,
      booking_ts,
      gps_latitude,
      gps_longitude,
      v_gps_latitude,
      v_gps_longitude
        )
    using
        "python distance.py"
    as
        (
        user_id int,
        vehicle_id int,
        booking_ts string,
        gps_latitude float,
        gps_longitude float,
        v_gps_latitude float,
        v_gps_longitude float,
        seconds int,
        meters int
        )
    ) tmp2
;
