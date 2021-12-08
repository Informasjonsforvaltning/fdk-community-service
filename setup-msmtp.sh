#!/bin/bash

echo "Setting up msmtp"

cat > ~/.msmtprc << EOL
# Set default values for all following accounts.
defaults
port 25
tls on

account default
auth off
host $SMTP_SERVER:$SMTP_PORT
domain $SMTP_HOSTNAME
add_missing_date_header on
EOL
