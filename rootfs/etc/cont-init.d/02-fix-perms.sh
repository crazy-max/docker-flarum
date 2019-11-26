#!/usr/bin/with-contenv sh

echo "Fixing perms..."
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
  /var/run/php-fpm \
  /var/tmp/nginx
