FROM nodebb/docker

COPY nodebb-theme-fdk ./nodebb-theme-fdk
RUN npm install ./nodebb-theme-fdk
