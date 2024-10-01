#!/bin/bash

echo "Setting up msmtp"

cat > /etc/msmtprc << EOL
# Set default values for all following accounts.
defaults
port $SMTP_PORT
tls on
tls_starttls off
tls_certcheck off
tls_trust_file $SMTP_TLS_CA
tls_host_override $SMTP_TLS_HOSTNAME

account default
auth off
host $SMTP_SERVER
domain $SMTP_HOSTNAME
from datalandsbyen@norge.no
add_missing_date_header on
EOL
