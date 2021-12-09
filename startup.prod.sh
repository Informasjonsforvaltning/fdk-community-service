#!/bin/bash

echo "Community Docker container has been started"

/setup-msmtp.sh

# Setup a cron schedule (every hour)
echo "0 * * * * TEST_MODE=$TEST_MODE TEST_EMAIL=$TEST_EMAIL API_TOKEN=$API_TOKEN API_TOKEN_WRITE=$API_TOKEN_WRITE BASE_URL='https://datalandsbyen.norge.no' /run.sh >> /usr/src/app/files/log/cron.log 2>&1
# This extra line makes it a valid cron" > scheduler.txt

crontab scheduler.txt
cron -f &

node ./nodebb activate nodebb-plugin-fdk-consent
node ./nodebb activate nodebb-plugin-fdk-sso
node ./nodebb activate nodebb-plugin-calendar
node ./nodebb activate nodebb-plugin-dbsearch
node ./nodebb activate nodebb-plugin-gdpr
node ./nodebb activate nodebb-plugin-google-analytics
node ./nodebb activate nodebb-plugin-write-api
node ./nodebb reset -t nodebb-theme-fdk
node ./nodebb build
node ./nodebb start