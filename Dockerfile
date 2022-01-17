FROM nodebb/docker:1.19

USER root

RUN apt-get update && \
    apt-get -y install cron jq msmtp && \
    apt-get -y remove exim4-base exim4-config exim4-daemon-light && \
    ln -s /usr/bin/msmtp /usr/sbin/sendmail

COPY nodebb-theme-fdk ./nodebb-theme-fdk
COPY nodebb-plugin-fdk-sso ./nodebb-plugin-fdk-sso
COPY nodebb-plugin-fdk-consent ./nodebb-plugin-fdk-consent

COPY ./nodebb-patch/detail.js ./public/src/client/flags/detail.js
COPY ./nodebb-patch/username.js ./public/src/client/account/edit/username.js

COPY mail-template-delete-7days.html /
COPY mail-template-deleted.html /

RUN chown 1000:1000 -R \
    ./nodebb-theme-fdk \
    ./nodebb-plugin-fdk-sso \
    ./nodebb-plugin-fdk-consent \
    ./public/src/client/flags/detail.js \
    ./public/src/client/account/edit/username.js

COPY run.sh /run.sh
COPY startup.sh /startup.sh
COPY setup-msmtp.sh /
RUN chmod +x /run.sh /startup.sh /setup-msmtp.sh

USER 1000
RUN npm install \
    ./nodebb-theme-fdk \
    ./nodebb-plugin-fdk-sso \
    ./nodebb-plugin-fdk-consent \
    nodebb-plugin-calendar \
    nodebb-plugin-gdpr \
    nodebb-plugin-google-analytics \
    nodebb-plugin-write-api && \
    npm audit fix --audit-level=high

RUN mkdir -p /usr/src/app/files/log

USER root
CMD /startup.sh

