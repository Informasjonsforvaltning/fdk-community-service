#!/bin/bash

echo "Setting up msmtp"

cat > ~/.msmtprc << EOL
# Set default values for all following accounts.
defaults
port $SMTP_PORT
tls on
tls_starttls on
tls_certcheck off

account default
auth off
host $SMTP_SERVER
domain $SMTP_HOSTNAME
from datalandsbyen@norge.no
add_missing_date_header on
EOL
