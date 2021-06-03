# fdk-community-service
Service hosting the FDK community forum service.

## Setup locally
The local instance is presetup. Start containers with docker-compose and open http://localhost:4567 in a browser.
```
docker-compose up -d
```

### Local admin
Username: **admin**<br/>
Password: **MyPassword**

### Environment variables
API_TOKEN: API Token used to access default API.<br/>
API_TOKEN_WRITE: API Token used to access write API.<br/>
SSMTP_SERVER: outlook.com<br/>
SSMTP_PORT=25<br/>
SSMTP_TLS=true<br/>
SSMTP_REWRITE_DOMAIN=norge.no<br/>
SSMTP_HOSTNAME=datalandsbyen.norge.no<br/>
SSMTP_USER=<br/>
SSMTP_PASS=

### Example SMTP config
SSMTP_SERVER=outlook.com<br/>
SSMTP_PORT=25<br/>
SSMTP_TLS=true<br/>
SSMTP_REWRITE_DOMAIN=norge.no<br/>
SSMTP_HOSTNAME=datalandsbyen.norge.no<br/>
SSMTP_USER=<br/>
SSMTP_PASS=