FROM node:lts AS builder
RUN npm install -g typescript

COPY nodebb-plugin-fdk-resource-link ./nodebb-plugin-fdk-resource-link

RUN cd nodebb-plugin-fdk-resource-link && \
    npm install && \
    npm run build-production


FROM ghcr.io/nodebb/nodebb:3.8.4

USER root

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install cron jq msmtp && \
    apt-get -y remove exim4-base exim4-config exim4-daemon-light && \
    ln -s /usr/bin/msmtp /usr/sbin/sendmail 

COPY ./nodebb-plugin-sso-oauth2-multiple ./nodebb-plugin-sso-oauth2-multiple
COPY --from=builder nodebb-plugin-fdk-resource-link/public ./nodebb-plugin-fdk-resource-link/public
COPY --from=builder nodebb-plugin-fdk-resource-link/build ./nodebb-plugin-fdk-resource-link/build
COPY --from=builder nodebb-plugin-fdk-resource-link/package.json ./nodebb-plugin-fdk-resource-link/package.json
COPY --from=builder nodebb-plugin-fdk-resource-link/plugin.json ./nodebb-plugin-fdk-resource-link/plugin.json
COPY --from=builder nodebb-plugin-fdk-resource-link/LICENSE ./nodebb-plugin-fdk-resource-link/LICENSE

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