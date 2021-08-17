FROM nodebb/docker:v1.17.1

COPY nodebb-theme-fdk ./nodebb-theme-fdk
COPY nodebb-plugin-fdk-sso ./nodebb-plugin-fdk-sso
COPY nodebb-plugin-fdk-consent ./nodebb-plugin-fdk-consent


COPY ./nodebb-patch/detail.js ./public/src/client/flags/detail.js
COPY ./nodebb-patch/username.js ./public/src/client/account/edit/username.js

RUN apt-get update && apt-get -y install cron jq ssmtp

COPY mail-template-delete-7days.html /
COPY mail-template-deleted.html /
COPY setup-ssmtp.sh /
RUN chmod 770 /setup-ssmtp.sh && /setup-ssmtp.sh

RUN npm install \
    ./nodebb-theme-fdk \
    ./nodebb-plugin-fdk-sso \
    ./nodebb-plugin-fdk-consent \
    nodebb-plugin-calendar \
    nodebb-plugin-gdpr \
    nodebb-plugin-google-analytics \
    nodebb-plugin-write-api
RUN npm audit fix

RUN mkdir -p /usr/src/app/files/log

ADD run.sh /run.sh
ADD startup.sh /startup.sh
RUN chmod +x /run.sh /startup.sh

CMD /startup.sh

