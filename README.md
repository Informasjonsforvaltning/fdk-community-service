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

## Environment variables
- `BASE_URL` - Base url of the site (for example https://datalandsbyen.norge.no).
- `API_TOKEN` - API Token used to access default API.
- `API_TOKEN_WRITE` - API Token used to access write API.
- `SMTP_SERVER` - The mail server (where the mail is sent to)
- `SMTP_PORT` - Portnumber of the mail server (25, 465, 587)
- `SMTP_HOSTNAME` - The full hostname.  Must be correctly formed, fully qualified domain name or GMail will reject connection.
- `TEST_MODE` - Run remove users script in test mode (true/false)
- `TEST_EMAIL` - Send notification emails to this address when in test mode
- `TOKEN_UID` - User id the API tokens belong to. This user is never deleted by the retention script.

## User retention
`user-retention.sh` runs from cron inside the container. Users who have not logged in for 365 days are
deleted, after warning emails 6 weeks, 1 week and 1 day before the deletion date. The deletion date is fixed
when the first warning is sent and is never earlier than 6 weeks after that warning, so users who are already
inactive for more than a year when the job is (re)enabled still get the full notice period. State is kept per
user in `/usr/src/app/files/retention/` and cleared when the user logs in again.

With `TEST_MODE=true` the periods are 3 days / 48h / 24h / 6h, all emails go to `TEST_EMAIL`, state is kept in
`/usr/src/app/files/retention-test/` and no users are deleted.

## Example SMTP config
- SSMTP_SERVER=outlook.com
- SSMTP_PORT=25
- SSMTP_TLS=true
- SSMTP_REWRITE_DOMAIN=norge.no
- SSMTP_HOSTNAME=datalandsbyen.norge.no
- SSMTP_USER=
- SSMTP_PASS=

## Running tests
Start your local instance
```
docker-compose up -d
```

Open Cypress interactively and run tests
```
cd e2e
npm run cypress:open
```

Run tests and store results in Cypress dasboard
```
cd e2e
npm run cypress:run
```
