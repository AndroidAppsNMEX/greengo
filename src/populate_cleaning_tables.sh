#! /bin/bash

echo "Starting..."


RUN_DATE=$1
RUN_DATE_NO_DASH=$2
query='''SELECT
      user_id,
   client_type,
   gps_latitude,
   gps_longitude,
      SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 1, 10) as creation_date,
      SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 12) as creation_hour
    FROM poc_analytics.STG_USER_ACTIVITIES
 WHERE
  SUBSTR(REPLACE(REPLACE(creation_date, '.', '-'), ' ', ''), 1, 10) = '${RUN_DATE}'
  '''

bq query --allow_large_results --replace --destination_table poc_analytics.CLN\$${RUN_DATE_NO_DASH} --use_legacy_sql=false ${query}



echo "All Done..."
