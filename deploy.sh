#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"
DEFAULT_CLONE_ROOT="${SCRIPT_DIR}/.."

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

clone_services() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: $(basename "$0") clone-services <base-org> <service1> [service2 ...]"
    return 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "git is required but not found in PATH"
    return 1
  fi

  local base_org="$1"
  shift

  local clone_root="${CLONE_ROOT:-$DEFAULT_CLONE_ROOT}"
  mkdir -p "$clone_root"

  local service
  for service in "$@"; do
    local target_dir="${clone_root}/${service}"
    local repo_url="https://github.com/${base_org}/${service}.git"

    if [[ -d "$target_dir/.git" ]]; then
      echo "Skipping ${service}: already cloned at ${target_dir}"
      continue
    fi
    if [[ -e "$target_dir" ]]; then
      echo "Skipping ${service}: path exists and is not a git repo (${target_dir})"
      continue
    fi

    echo "Cloning ${repo_url} -> ${target_dir}"
    git clone "$repo_url" "$target_dir"
  done
}

pull_services() {
  if ! command -v git >/dev/null 2>&1; then
    echo "git is required but not found in PATH"
    return 1
  fi

  local clone_root="${CLONE_ROOT:-$DEFAULT_CLONE_ROOT}"
  if [[ ! -d "$clone_root" ]]; then
    echo "Clone root does not exist: $clone_root"
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    local repo_dir
    while IFS= read -r repo_dir; do
      echo "Pulling $(basename "$repo_dir")"
      git -C "$repo_dir" pull --ff-only
    done < <(find "$clone_root" -mindepth 2 -maxdepth 2 -type d -name .git -print | sed 's|/\.git$||' | sort)
    return 0
  fi

  local service
  for service in "$@"; do
    local target_dir="${clone_root}/${service}"
    if [[ ! -d "$target_dir/.git" ]]; then
      echo "Skipping ${service}: not a git repo at ${target_dir}"
      continue
    fi
    echo "Pulling ${service}"
    git -C "$target_dir" pull --ff-only
  done
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>

Commands:
  bootstrap   Create missing .env files from .example templates
  clone-services Auto-clone repos: clone-services <base-org> <service1> [service2 ...]
  pull-services Pull updates: pull-services [service1 service2 ...]
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
  clone-services)
    shift || true
    clone_services "$@"
    ;;
  pull-services)
    shift || true
    pull_services "$@"
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
