FROM nodebb/docker:v1.17.1

COPY nodebb-theme-fdk ./nodebb-theme-fdk
COPY nodebb-plugin-fdk-sso ./nodebb-plugin-fdk-sso

COPY ./nodebb-patch/detail.js ./public/src/client/flags/detail.js
COPY ./nodebb-patch/username.js ./public/src/client/account/edit/username.js

RUN apt-get update && apt-get -y install cron jq ssmtp

COPY setup-ssmtp.sh /
RUN chmod 770 /setup-ssmtp.sh && /setup-ssmtp.sh

RUN npm install \
    ./nodebb-theme-fdk \
    ./nodebb-plugin-fdk-sso \
    nodebb-plugin-calendar \
    nodebb-plugin-gdpr \
    nodebb-plugin-write-api
RUN npm audit fix

ADD run.sh /run.sh
ADD startup.sh /startup.sh
RUN chmod +x /run.sh /startup.sh

CMD /startup.sh

