#!/usr/bin/with-contenv sh

if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g flarum)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^flarum:\([^:]*\):[0-9]*/flarum:\1:${PGID}/" /etc/group
  sed -i -e "s/^flarum:\([^:]*\):\([0-9]*\):[0-9]*/flarum:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u flarum)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^flarum:\([^:]*\):[0-9]*:\([0-9]*\)/flarum:\1:${PUID}:\2/" /etc/passwd
fi
