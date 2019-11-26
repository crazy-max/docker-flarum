#!/usr/bin/with-contenv bash

function fixperms() {
  for folder in $@; do
    if $(find ${folder} ! -user flarum -o ! -group flarum | egrep '.' -q); then
      echo "Fixing permissions in $folder..."
      chown -R flarum. "${folder}"
    else
      echo "Permissions already fixed in ${folder}"
    fi
  done
}

# From https://github.com/docker-library/mariadb/blob/master/docker-entrypoint.sh#L21-L41
# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

MEMORY_LIMIT=${MEMORY_LIMIT:-256M}
UPLOAD_MAX_SIZE=${UPLOAD_MAX_SIZE:-16M}
OPCACHE_MEM_SIZE=${OPCACHE_MEM_SIZE:-128}
REAL_IP_FROM=${REAL_IP_FROM:-0.0.0.0/32}
REAL_IP_HEADER=${REAL_IP_HEADER:-X-Forwarded-For}
LOG_IP_VAR=${LOG_IP_VAR:-remote_addr}

FLARUM_DEBUG=${FLARUM_DEBUG:-false}
#FLARUM_BASE_URL=${FLARUM_BASE_URL:-http://flarum.docker}
FLARUM_FORUM_TITLE="${FLARUM_FORUM_TITLE:-Flarum Dockerized}"
FLARUM_API_PATH="${FLARUM_API_PATH:-api}"
FLARUM_ADMIN_PATH="${FLARUM_ADMIN_PATH:-admin}"

#DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-flarum}
DB_USER=${DB_USER:-flarum}
#DB_PASSWORD=${DB_PASSWORD:-asupersecretpassword}
DB_PREFIX=${DB_PREFIX:-flarum_}
DB_TIMEOUT=${DB_TIMEOUT:-60}

# PHP
echo "Setting PHP-FPM configuration..."
sed -e "s/@MEMORY_LIMIT@/$MEMORY_LIMIT/g" \
  -e "s/@UPLOAD_MAX_SIZE@/$UPLOAD_MAX_SIZE/g" \
  /tpls/etc/php7/php-fpm.d/www.conf > /etc/php7/php-fpm.d/www.conf
echo "Setting PHP INI configuration..."
sed -i -e "s|memory_limit.*|memory_limit = ${MEMORY_LIMIT}|" /etc/php7/php.ini

# OpCache
echo "Setting OpCache configuration..."
sed -e "s/@OPCACHE_MEM_SIZE@/$OPCACHE_MEM_SIZE/g" \
  /tpls/etc/php7/conf.d/opcache.ini > /etc/php7/conf.d/opcache.ini

# Nginx
echo "Setting Nginx configuration..."
sed -e "s#@UPLOAD_MAX_SIZE@#$UPLOAD_MAX_SIZE#g" \
  -e "s#@REAL_IP_FROM@#$REAL_IP_FROM#g" \
  -e "s#@REAL_IP_HEADER@#$REAL_IP_HEADER#g" \
  -e "s#@LOG_IP_VAR@#$LOG_IP_VAR#g" \
  /tpls/etc/nginx/nginx.conf > /etc/nginx/nginx.conf

echo "Initializing files and folders..."
mkdir -p /data/assets /data/extensions/.cache /data/storage
touch /data/extensions/list
cp -Rf /opt/flarum/public/assets /data
cp -Rf /opt/flarum/storage /data
rm -rf /opt/flarum/extensions /opt/flarum/public/assets /opt/flarum/storage
ln -sf /data/assets /opt/flarum/public/assets
ln -sf /data/extensions /opt/flarum/extensions
ln -sf /data/storage /opt/flarum/storage
chown -h flarum. /opt/flarum/extensions /opt/flarum/public/assets /opt/flarum/storage
fixperms /data/assets /data/extensions /data/storage /opt/flarum/vendor

echo "Checking parameters..."
if [ -z "$FLARUM_BASE_URL" ]; then
  >&2 echo "ERROR: FLARUM_BASE_URL must be defined"
  exit 1
fi

echo "Checking database connection..."
if [ -z "$DB_HOST" ]; then
  >&2 echo "ERROR: DB_HOST must be defined"
  exit 1
fi
file_env 'DB_USER'
file_env 'DB_PASSWORD'
if [ -z "$DB_PASSWORD" ]; then
  >&2 echo "ERROR: Either DB_PASSWORD or DB_PASSWORD_FILE must be defined"
  exit 1
fi
dbcmd="mysql -h ${DB_HOST} -P ${DB_PORT} -u "${DB_USER}" "-p${DB_PASSWORD}""

echo "Waiting ${DB_TIMEOUT}s for database to be ready..."
counter=1
while ! ${dbcmd} -e "show databases;" > /dev/null 2>&1; do
  sleep 1
  counter=$((counter + 1))
  if [ ${counter} -gt ${DB_TIMEOUT} ]; then
    >&2 echo "ERROR: Failed to connect to database on $DB_HOST"
    exit 1
  fi;
done
echo "Database ready!"

if [ ! -f /data/assets/rev-manifest.json ]; then
  echo "First install detected..."
su-exec flarum:flarum cat > /tmp/config.yml <<EOL
debug: ${FLARUM_DEBUG}
baseUrl: ${FLARUM_BASE_URL}
databaseConfiguration:
  driver: mysql
  host: ${DB_HOST}
  database: ${DB_NAME}
  username: ${DB_USER}
  password: ${DB_PASSWORD}
  prefix: ${DB_PREFIX}
  port: ${DB_PORT}
adminUser:
  username: flarum
  password: flarum
  password_confirmation: flarum
  email: flarum@flarum.docker
settings:
  forum_title: ${FLARUM_FORUM_TITLE}
EOL
  su-exec flarum:flarum php flarum install --file=/tmp/config.yml
  echo ">>"
  echo ">> WARNING: Flarum has been installed with the default credentials (flarum/flarum)"
  echo ">> Please connect to ${FLARUM_BASE_URL} and change them!"
  echo ">>"
fi

echo "Creating Flarum config file..."
su-exec flarum:flarum cat > /opt/flarum/config.php <<EOL
<?php return array (
  'debug' => ${FLARUM_DEBUG},
  'database' =>
  array (
    'driver' => 'mysql',
    'host' => '${DB_HOST}',
    'port' => ${DB_PORT},
    'database' => '${DB_NAME}',
    'username' => '${DB_USER}',
    'password' => '${DB_PASSWORD}',
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '${DB_PREFIX}',
    'strict' => false,
    'engine' => 'InnoDB',
    'prefix_indexes' => true,
  ),
  'url' => '${FLARUM_BASE_URL}',
  'paths' =>
  array (
    'api' => '${FLARUM_API_PATH}',
    'admin' => '${FLARUM_ADMIN_PATH}',
  ),
);
EOL

if [ -s "/data/extensions/list" ]; then
  while read extension; do
    test -z "${extension}" && continue
    extensions="${extensions}${extension} "
  done < /data/extensions/list
  echo "Installing additional extensions..."
  COMPOSER_CACHE_DIR="/data/extensions/.cache" su-exec flarum:flarum composer require --working-dir /opt/flarum ${extensions}
fi

su-exec flarum:flarum php flarum migrate
su-exec flarum:flarum php flarum cache:clear
