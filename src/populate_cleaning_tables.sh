#! /bin/bash

echo "Starting..."


RUN_DATE=$1
RUN_DATE_NO_DASH=$2

echo "USER ACTIVITIES for $RUN_DATE..."
bq query --allow_large_results --replace --destination_table poc_analytics.CLN_USER_ACTIVITIES\$${RUN_DATE_NO_DASH} --use_legacy_sql=false  --parameter=run_date:STRING:${RUN_DATE} "$(cat /home/hahavelka/greengo/src/SQL/CLN_USER_ACTIVITIES.sql)"

echo "RENTALS for $RUN_DATE..."
bq query --allow_large_results --replace --destination_table poc_analytics.CLN_RENTALS\$${RUN_DATE_NO_DASH} --use_legacy_sql=false  --parameter=run_date:STRING:${RUN_DATE} "$(cat /home/hahavelka/greengo/src/SQL/CLN_RENTALS.sql)"

echo "VEHICLE POSITION for $RUN_DATE..."
bq query --allow_large_results --replace --destination_table poc_analytics.CLN_VEHICLE_POSITION\$${RUN_DATE_NO_DASH} --use_legacy_sql=false  --parameter=run_date:STRING:${RUN_DATE} "$(cat /home/hahavelka/greengo/src/SQL/CLN_VEHICLE_POSITION.sql)"

echo "All Done..."
