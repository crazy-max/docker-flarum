#!/bin/sh
set -eu

active=$(s6-rc -a list)
printf '%s\n' "$active" | grep -qx config

case "$1" in
  web)
    expected="nginx php-fpm"
    absent="cron"
    curl -fsS -o /dev/null http://127.0.0.1:8000
    ;;
  cron)
    expected="cron"
    absent="nginx php-fpm"
    ;;
  *)
    exit 1
    ;;
esac

for service in $expected; do
  printf '%s\n' "$active" | grep -qx "$service"
  test "$(s6-svstat -o up,wantedup "/run/service/$service")" = "true true"
done

for service in $absent; do
  if printf '%s\n' "$active" | grep -qx "$service"; then
    echo "Unexpected active service: $service" >&2
    exit 1
  fi
done
