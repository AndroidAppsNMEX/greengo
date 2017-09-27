#! /bin/bash

echo "Starting..."


RUN_DATE=$1
RUN_DATE_NO_DASH=$2

echo "Extracting data..."
bq extract --destination_format=AVRO poc_analytics.WRK_NO_BOOKINGS\$${RUN_DATE_NO_DASH} gs://poc-data-greengo/greengo/wrk_no_bookings/00*_0

echo "Moving to GCS..."
gsutil cp gs://poc-data-greengo/greengo/wrk_no_bookings/00000000000000_0 ./

#Piece of code for the init actions
#echo "Downloading python and copying it in the HDFS FS..."
#gsutil cp gs://poc-data-greengo/distance_no_bookings.py ./
#hdfs dfs -put -f ./distance_no_bookings.py /tmp/

echo "Downloading avro-tools..."
wget http://apache.uvigo.es/avro/avro-1.8.2/java/avro-tools-1.8.2.jar

echo "Calculating AVRO Schema..."
java -jar avro-tools-1.8.2.jar getschema ./00000000000000_0 > schema.avsc

echo "Moving schema to GCS..."
gsutil cp ./schema.avsc gs://poc-data-greengo/schema_no_bookings.avsc

echo "Running Hive Job and calculating distances..."
gcloud dataproc jobs submit hive --cluster poc-data-greengo --region europe-west1 -f /home/hahavelka/greengo/src/SQL/WRK_NO_BOOKINGS_DISTANCE.hql --params=RUN_DATE=${RUN_DATE}

echo "Loading back to BigQuery..."
bq load --replace --source_format=AVRO poc_analytics.WRK_NO_BOOKINGS_DISTANCE\$${RUN_DATE_NO_DASH} gs://poc-data-greengo/greengo/wrk_no_bookings_distance/booking_date=\$RUN_DATE/*

echo "All Done"
