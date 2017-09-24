#! /bin/bash

echo "Starting..."


RUN_DATE=$1
RUN_DATE_NO_DASH=$2

echo "Populating WRK_NO_BOOKINGS for $RUN_DATE..."
bq query --allow_large_results --replace --destination_table poc_analytics.WRK_NO_BOOKINGS\$${RUN_DATE_NO_DASH} --use_legacy_sql=false  --parameter=run_date:STRING:${RUN_DATE} "$(cat /home/hahavelka/greengo/src/SQL/WRK_NO_BOOKINGS.sql)"

echo "All Done..."
