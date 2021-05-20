FROM nodebb/docker:latest-v1.17.x

COPY nodebb-theme-fdk ./nodebb-theme-fdk
COPY nodebb-plugin-fdk-sso ./nodebb-plugin-fdk-sso

RUN npm install \
    ./nodebb-theme-fdk \
    ./nodebb-plugin-fdk-sso \
    nodebb-plugin-calendar \
    nodebb-plugin-gdpr

CMD node ./nodebb activate nodebb-plugin-fdk-sso ; \
    node ./nodebb activate nodebb-plugin-calendar ; \
    node ./nodebb activate nodebb-plugin-dbsearch ; \
    node ./nodebb activate nodebb-plugin-gdpr ; \
    node ./nodebb reset -t nodebb-theme-fdk ; \
    node ./nodebb build ;  \
    node ./nodebb start
