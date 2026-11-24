#!/bin/sh
# Start script for the ChatDev web front (Caddy) on Railway.
set -eu

if [ -z "${CHATDEV_PASSWORD:-}" ]; then
  echo "chatdev-web: CHATDEV_PASSWORD is empty; refusing to serve ChatDev without a login." >&2
  exit 1
fi
if [ -z "${BACKEND_HOST:-}" ]; then
  echo "chatdev-web: BACKEND_HOST is empty (it should reference the backend's private domain)." >&2
  exit 1
fi
export CHATDEV_USERNAME="${CHATDEV_USERNAME:-admin}"
export BACKEND_PORT="${BACKEND_PORT:-6400}"
export PORT="${PORT:-8080}"
CHATDEV_PASSWORD_HASH="$(caddy hash-password --plaintext "$CHATDEV_PASSWORD")"
export CHATDEV_PASSWORD_HASH

# Railway shows the host's CPU count inside the container; size Go to the cgroup quota.
if [ -z "${GOMAXPROCS:-}" ] && [ -r /sys/fs/cgroup/cpu.max ]; then
  read -r quota period < /sys/fs/cgroup/cpu.max || true
  if [ "${quota:-max}" != "max" ] && [ -n "${period:-}" ]; then
    n=$(( (quota + period - 1) / period )); [ "$n" -ge 1 ] || n=1; [ "$n" -le 4 ] || n=4
    export GOMAXPROCS="$n"
  fi
fi
export GOMAXPROCS="${GOMAXPROCS:-2}"

echo "chatdev-web: listening on :$PORT, backend $BACKEND_HOST:$BACKEND_PORT"
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
