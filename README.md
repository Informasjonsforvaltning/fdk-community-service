# fdk-community-service
Service hosting the FDK community forum service.

## Setup locally
The local instance is presetup. Start containers with docker-compose and open http://localhost:4567 in a browser.
```
docker-compose up -d
```

### Environment variables
- `API_TOKEN` - API Token used to access default API.
- `API_TOKEN_WRITE` - API Token used to access write API.
- `SSMTP_SERVER` - The mail server (where the mail is sent to)
- `SSMTP_PORT` - Portnumber of the mail server (25, 465, 587)
- `SSMTP_TLS` - Use SSL/TLS before starting negotiation (true/false)
- `SSMTP_REWRITE_DOMAIN` - The address where the mail appears to come from for user authentication.
- `SSMTP_HOSTNAME` - The full hostname.  Must be correctly formed, fully qualified domain name or GMail will reject connection.
- `SSMTP_USER` - Username
- `SSMTP_PASS` - Password

### Local admin
Username: **admin**<br/>
Password: **MyPassword**

### Example SMTP config
- SSMTP_SERVER=outlook.com
- SSMTP_PORT=25
- SSMTP_TLS=true
- SSMTP_REWRITE_DOMAIN=norge.no
- SSMTP_HOSTNAME=datalandsbyen.norge.no
- SSMTP_USER=
- SSMTP_PASS=