#!/usr/bin/with-contenv sh
# shellcheck shell=sh

CRONTAB_PATH="/var/spool/cron/crontabs"
SIDECAR_CRON=${SIDECAR_CRON:-0}
CRON_SCHEDULE="${CRON_SCHEDULE-* * * * *}"

if [ "$SIDECAR_CRON" != "1" ]; then
  exit 0
fi

echo ">>"
echo ">> Sidecar cron container detected for Flarum"
echo ">>"

rm -rf "${CRONTAB_PATH}"
mkdir -p "${CRONTAB_PATH}"
touch "${CRONTAB_PATH}/flarum"

if [ -n "$CRON_SCHEDULE" ]; then
  echo "Creating Flarum scheduler cron task with the following period fields: $CRON_SCHEDULE"
  echo "${CRON_SCHEDULE} sh /usr/local/bin/flarum_scheduler" >>"${CRONTAB_PATH}/flarum"
else
  echo "CRON_SCHEDULE env var empty..."
fi

chmod 0755 "${CRONTAB_PATH}"
chmod 0644 "${CRONTAB_PATH}/flarum"

mkdir -p /etc/services.d/cron
cat >/etc/services.d/cron/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
exec busybox crond -f -L /dev/stdout -c ${CRONTAB_PATH}
EOL
chmod +x /etc/services.d/cron/run
