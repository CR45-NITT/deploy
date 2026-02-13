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

- `./deploy.sh clone-services <base-org> <service1> [service2 ...]`
- `./deploy.sh pull-services [service1 service2 ...]`
- `./deploy.sh stop`
- `./deploy.sh down`
- `./deploy.sh restart`
- `./deploy.sh logs`
- `./deploy.sh ps`
- `./deploy.sh config`

## Clone service repositories

Clone selected repositories from a GitHub organization:

- `./deploy.sh clone-services CR45-NITT service-identity service-timetable adapter-matrix`

By default, repos are cloned into `../services` relative to this folder.
Override clone destination with `CLONE_ROOT`:

- `CLONE_ROOT=/path/to/folder ./deploy.sh clone-services CR45-NITT service-identity service-timetable`

Pull updates for all cloned repos:

- `./deploy.sh pull-services`

Pull updates for specific repos only:

- `./deploy.sh pull-services service-identity service-timetable`
