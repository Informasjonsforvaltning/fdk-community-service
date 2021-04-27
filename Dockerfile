FROM nodebb/docker:latest-v1.16.x

COPY nodebb-theme-fdk ./nodebb-theme-fdk
COPY nodebb-plugin-fdk-sso ./nodebb-plugin-fdk-sso
RUN npm install ./nodebb-theme-fdk ./nodebb-plugin-fdk-sso

CMD node ./nodebb activate nodebb-plugin-fdk-sso ; \
    node ./nodebb reset -t nodebb-theme-fdk ; \
    node ./nodebb build ;  \
    node ./nodebb start

WORKDIR config