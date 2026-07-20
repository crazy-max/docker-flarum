#!/usr/bin/with-contenv bash
# shellcheck shell=bash

SIDECAR_CRON=${SIDECAR_CRON:-0}

if [ "$SIDECAR_CRON" = "1" ]; then
  exit 0
fi

mkdir -p /etc/services.d/nginx
cat > /etc/services.d/nginx/run <<EOL
#!/usr/bin/execlineb -P
s6-setuidgid ${PUID}:${PGID}
nginx -g "daemon off;"
EOL
chmod +x /etc/services.d/nginx/run

mkdir -p /etc/services.d/php-fpm
cat > /etc/services.d/php-fpm/run <<EOL
#!/usr/bin/execlineb -P
s6-setuidgid ${PUID}:${PGID}
php-fpm84 -F
EOL
chmod +x /etc/services.d/php-fpm/run
