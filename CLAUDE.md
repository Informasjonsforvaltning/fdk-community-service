# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FDK Community Service hosts a NodeBB-based community forum for the Norwegian Data Catalog (Felles datakatalog). The application runs in Docker containers with custom NodeBB plugins and includes automated user retention/GDPR compliance management.

## Architecture

### Core Components

**NodeBB Base**: Built on NodeBB 4.6.0 (forum software)
- Database: MongoDB
- Three custom plugins extend NodeBB functionality
- Patches applied to core NodeBB and some plugins

**Custom Plugins** (located in `nodebb-plugin-*` directories):
1. `nodebb-plugin-sso-oauth2-multiple`: OAuth2 SSO authentication
2. `nodebb-plugin-fdk-resource-link`: Composer button to link data.norge.no resources
3. `nodebb-plugin-fdk-consent`: GDPR consent page management

**User Retention System** (`user-retention.sh`):
- Runs hourly in production, every 15 minutes in dev, via cron
- Removes users who haven't logged in for 365 days (3 days in test mode)
- Sends three warning emails before deletion: 6 weeks, 1 week and 1 day before (48h, 24h and 6h in test mode)
- The deletion date is fixed when the first warning is sent, and is never earlier than 6 weeks after it. Users who are already past the limit when the job (re)starts therefore still get the full notice period
- Per-user state (scheduled deletion date, warnings sent) lives in `/usr/src/app/files/retention/` (`retention-test/` in test mode) and is cleared when the user logs in again
- Removes users who don't consent to GDPR within 1 hour of joining
- Email templates: `mail-template-delete-6weeks.html`, `mail-template-delete-7days.html`, `mail-template-delete-1days.html`, `mail-template-deleted.html`. Placeholders: `@@NAME@@`, `@@EMAIL@@`, `@@USERSLUG@@`, `@@UID@@`, `@@BASE_URL@@`, `@@DELETE_DATE@@`

### Plugin Structure

Each NodeBB plugin follows a standard structure:
- `plugin.json`: Plugin metadata and hook definitions
- `library.js`: Server-side hook implementations
- `static/`: Client-side scripts and templates
- `languages/`: Translation files

Plugins use NodeBB's hook system (e.g., `static:app.load`, `filter:admin.header.build`) to integrate with the forum.

### Patches

Custom patches in `patches/` override default behavior:
- `patches/nodebb/`: Core NodeBB modifications
- `patches/nodebb-plugin-ntfy/`: Notification plugin patches
- `patches/nodebb-theme-harmony/`: Theme patches

These are copied into the container during Docker build (see Dockerfile:17-19).

## Development Commands

### Local Development

Start local instance:
```bash
docker-compose up -d
```

Access at: http://localhost:4567
- Username: **admin**
- Password: **MyPassword**

Stop containers:
```bash
docker-compose down
```

View logs:
```bash
docker-compose logs -f app
```

### Testing

Run E2E tests interactively:
```bash
cd e2e
npm run cypress:open
```

Run E2E tests headlessly:
```bash
cd e2e
npm run cypress:run
```

Test files are in `e2e/cypress/e2e/specs/` (TypeScript).

### Plugin Development

Lint OAuth plugin:
```bash
cd nodebb-plugin-sso-oauth2-multiple
npm run lint
```

After modifying plugins, rebuild the Docker container:
```bash
docker-compose up -d --build
```

## Key Files

- `Dockerfile`: Development container build
- `prod.Dockerfile`: Production container build
- `startup.sh`: Development entrypoint (activates plugins, sets up cron)
- `startup.prod.sh`: Production entrypoint
- `user-retention.sh`: User cleanup and GDPR compliance script
- `setup-msmtp.sh`: Email configuration
- `docker-compose.yml`: Local development orchestration
- `nodebb/config.json`: NodeBB configuration (MongoDB connection, port)

## Environment Variables

Required for production:
- `BASE_URL`: Forum URL (e.g., https://datalandsbyen.norge.no)
- `API_TOKEN`: Read-only API access token
- `API_TOKEN_WRITE`: Write API access token (for user deletion)
- `TOKEN_UID`: User ID for API operations
- `SMTP_SERVER`: Mail server address
- `SMTP_PORT`: Mail server port (25, 465, 587)
- `SMTP_HOSTNAME`: Fully qualified domain name for mail
- `TEST_MODE`: Set to "true" for testing (reduces retention timeouts)
- `TEST_EMAIL`: Email address for test mode notifications

## Important Notes

- Plugin activation happens in `startup.sh` via `node ./nodebb activate <plugin-id>`
- User retention script runs hourly in production (startup.prod.sh) and every 15 minutes in dev (startup.sh)
- Mail server is msmtp (sendmail replacement)
- The cron job logs to `/usr/src/app/files/log/cron.log`
- Local setup includes pre-configured MongoDB with initialization script (`mongo/init.js`)
