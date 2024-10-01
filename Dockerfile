FROM ghcr.io/nodebb/nodebb:3.10.0

USER root

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install cron jq msmtp curl && \
    apt-get -y remove exim4-base exim4-config exim4-daemon-light && \
    ln -s /usr/bin/msmtp /usr/sbin/sendmail 

COPY ./nodebb-plugin-sso-oauth2-multiple ./nodebb-plugin-sso-oauth2-multiple
COPY ./nodebb-plugin-fdk-resource-link ./nodebb-plugin-fdk-resource-link
COPY ./nodebb-patch/controllers/authentication.js ./src/controllers/authentication.js

COPY mail-template-delete-7days.html /
COPY mail-template-deleted.html /

RUN chown 1000:1000 -R \
    ./nodebb-plugin-fdk-resource-link \
    ./nodebb-plugin-sso-oauth2-multiple

COPY nodebb/config.json /opt/config
COPY send-emails.sh /usr/local/bin
COPY startup.sh /usr/local/bin
COPY setup-msmtp.sh /usr/local/bin
RUN chmod +x /usr/local/bin/send-emails.sh \
    /usr/local/bin/startup.sh \
    /usr/local/bin/setup-msmtp.sh

RUN npm install \
    ./nodebb-plugin-sso-oauth2-multiple \
    ./nodebb-plugin-fdk-resource-link

RUN npm audit fix; exit 0
    
RUN mkdir -p /usr/src/app/files/log

ENTRYPOINT ["tini", "--", "startup.sh"]
