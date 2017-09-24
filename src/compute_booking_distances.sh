bq extract --destination_format=AVRO poc_analytics.WRK_BOOKINGS\$ gs://poc-data-greengo/greengo/wrk_bookings/00*_0

gsutil cp gs://poc-data-greengo/greengo/wrk_bookings/00000000000000_0 ./

wget http://apache.uvigo.es/avro/avro-1.8.2/java/avro-tools-1.8.2.jar
java -jar avro-tools-1.8.2.jar getschema ./00000000000000_0 > schema.avsc

gsutil cp ./schema.avsc gs://poc-data-greengo/schema_bookings.avsc

bq load --replace --source_format=AVRO poc_analytics.WRK_BOOKINGS_DISTANCE\$20170905 gs://poc-data-greengo/greengo/wrk_bookings_distance/booking_date=2017-09-05/*
