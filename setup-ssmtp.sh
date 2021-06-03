#!/bin/bash

echo "Setting up ssmtp"

cat > /etc/ssmtp/ssmtp.conf << EOL
# Modified config file for sSMTP sendmail
Mailhub=$SSMTP_SERVER:$SSMTP_PORT
UseSTARTTLS=$SSMTP_TLS
RewriteDomain=$SSMTP_REWRITE_DOMAIN
Hostname=$SSMTP_HOSTNAME
FromLineOverride=YES
EOL

if [ "$SSMTP_USER" != "" ]
then
    echo "AuthUser=$SSMTP_USER" >> /etc/ssmtp/ssmtp.conf
    echo "AuthPass=$SSMTP_PASS" >> /etc/ssmtp/ssmtp.conf
fi


echo $(head -n 1 /etc/ssmtp/ssmtp.conf)
