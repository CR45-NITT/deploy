#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"

ensure_env_file() {
  local target="$1"
  local example="$2"
  if [[ ! -f "$target" ]]; then
    cp "$example" "$target"
    echo "Created $(basename "$target") from template. Fill in real values before production use."
  fi
}

bootstrap_envs() {
  ensure_env_file "${SCRIPT_DIR}/.env.postgres" "${SCRIPT_DIR}/.env.postgres.example"
  ensure_env_file "${SCRIPT_DIR}/.env.service-identity" "${SCRIPT_DIR}/.env.service-identity.example"
  ensure_env_file "${SCRIPT_DIR}/.env.service-timetable" "${SCRIPT_DIR}/.env.service-timetable.example"
  ensure_env_file "${SCRIPT_DIR}/.env.adapter-matrix" "${SCRIPT_DIR}/.env.adapter-matrix.example"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  bootstrap   Create missing .env files from .example templates
  up          Build and start the stack in detached mode
  stop        Stop containers without removing them
  down        Stop and remove containers
  restart     Restart all services
  logs        Follow logs for all services
  ps          Show service status
  config      Render composed config
EOF
}

cmd="${1:-}"
case "$cmd" in
  bootstrap)
    bootstrap_envs
    ;;
  up)
    bootstrap_envs
    docker compose -f "$COMPOSE_FILE" up --build -d
    ;;
  stop)
    docker compose -f "$COMPOSE_FILE" stop
    ;;
  down)
    docker compose -f "$COMPOSE_FILE" down
    ;;
  restart)
    docker compose -f "$COMPOSE_FILE" restart
    ;;
  logs)
    docker compose -f "$COMPOSE_FILE" logs -f
    ;;
  ps)
    docker compose -f "$COMPOSE_FILE" ps
    ;;
  config)
    docker compose -f "$COMPOSE_FILE" config
    ;;
  *)
    usage
    exit 1
    ;;
esac
