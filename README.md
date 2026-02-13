# Deployment

This folder contains stack-level deployment assets:

- [docker-compose.yml](docker-compose.yml)
- [Caddyfile](Caddyfile)
- environment templates (`.env.*.example`)
- [deploy.sh](deploy.sh)

## Quick start

1. Bootstrap local env files from templates:
   - `./deploy.sh bootstrap`
2. Edit generated `.env.*` files with real values.
3. Start stack:
   - `./deploy.sh up`

## Useful commands

- `./deploy.sh stop`
- `./deploy.sh down`
- `./deploy.sh restart`
- `./deploy.sh logs`
- `./deploy.sh ps`
- `./deploy.sh config`
