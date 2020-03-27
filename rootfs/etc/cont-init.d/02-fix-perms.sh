#!/usr/bin/with-contenv sh

echo "Fixing perms..."
mkdir -p /data \
  /var/run/nginx \
  /var/run/php-fpm
chown flarum. \
  /data \
  /opt/flarum \
  /opt/flarum/composer.json \
  /opt/flarum/composer.lock
chown -R flarum. \
  /tpls \
  /var/lib/nginx \
  /var/log/nginx \
  /var/log/php7 \
  /var/run/nginx \
  /var/run/php-fpm
