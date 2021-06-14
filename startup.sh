#!/bin/bash

echo "Community Docker container has been started"

# Setup a cron schedule (every hour)
echo "0 * * * * /run.sh >> /var/log/cron.log 2>&1
# This extra line makes it a valid cron" > scheduler.txt

crontab scheduler.txt
cron -f &

/setup-ssmtp.sh

node ./nodebb activate nodebb-plugin-fdk-sso
node ./nodebb activate nodebb-plugin-calendar
node ./nodebb activate nodebb-plugin-dbsearch
node ./nodebb activate nodebb-plugin-gdpr
node ./nodebb activate nodebb-plugin-write-api
node ./nodebb reset -t nodebb-theme-fdk
node ./nodebb build
node ./nodebb start