#!/bin/bash

echo "Setting up msmtp"

cat > /etc/msmtprc << EOL
# Set default values for all following accounts.
defaults
port $SMTP_PORT
tls on
tls_starttls on
tls_certcheck off
tls_trust_file $SMTP_CA

account default
auth off
host $SMTP_SERVER
domain $SMTP_HOSTNAME
from datalandsbyen@norge.no
add_missing_date_header on
EOL
