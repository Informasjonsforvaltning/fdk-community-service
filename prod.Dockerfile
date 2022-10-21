FROM node:18-alpine3.16 AS builder
RUN npm install -g typescript

COPY nodebb-plugin-fdk-resource-link ./nodebb-plugin-fdk-resource-link

RUN cd nodebb-plugin-fdk-resource-link && \
    npm install && \
    npm run build-production


FROM nodebb/docker:2.5.7

USER root

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install cron jq msmtp && \
    apt-get -y remove exim4-base exim4-config exim4-daemon-light && \
    ln -s /usr/bin/msmtp /usr/sbin/sendmail

COPY nodebb-theme-fdk ./nodebb-theme-fdk
COPY nodebb-plugin-fdk-sso ./nodebb-plugin-fdk-sso
COPY nodebb-plugin-fdk-consent ./nodebb-plugin-fdk-consent
COPY --from=builder nodebb-plugin-fdk-resource-link/public ./nodebb-plugin-fdk-resource-link/public
COPY --from=builder nodebb-plugin-fdk-resource-link/build ./nodebb-plugin-fdk-resource-link/build
COPY --from=builder nodebb-plugin-fdk-resource-link/package.json ./nodebb-plugin-fdk-resource-link/package.json
COPY --from=builder nodebb-plugin-fdk-resource-link/plugin.json ./nodebb-plugin-fdk-resource-link/plugin.json
COPY --from=builder nodebb-plugin-fdk-resource-link/LICENSE ./nodebb-plugin-fdk-resource-link/LICENSE

COPY ./nodebb-patch/detail.js ./public/src/client/flags/detail.js
COPY ./nodebb-patch/username.js ./public/src/client/account/edit/username.js

COPY mail-template-delete-7days.html /
COPY mail-template-deleted.html /

RUN chown 1000:1000 -R \
    ./nodebb-theme-fdk \
    ./nodebb-plugin-fdk-sso \
    ./nodebb-plugin-fdk-consent \
    ./nodebb-plugin-fdk-resource-link \
    ./public/src/client/flags/detail.js \
    ./public/src/client/account/edit/username.js

COPY run.sh /run.sh
COPY startup.prod.sh /startup.sh
COPY setup-msmtp.sh /
RUN chmod +x /run.sh /startup.sh /setup-msmtp.sh

USER 1000

RUN npm install \
    ./nodebb-theme-fdk \
    ./nodebb-plugin-fdk-sso \
    ./nodebb-plugin-fdk-consent \
    ./nodebb-plugin-fdk-resource-link \
    nodebb-plugin-calendar \
    nodebb-plugin-gdpr \
    nodebb-plugin-google-analytics

RUN mkdir -p /usr/src/app/files/log

USER root
CMD /startup.sh

