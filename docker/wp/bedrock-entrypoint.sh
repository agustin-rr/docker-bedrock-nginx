#!/usr/bin/env bash
set -Eeuo pipefail

uid="$(id -u)"
gid="$(id -g)"
if [ "$uid" = '0' ]; then
  user='www-data'
  group='www-data'
else
  user="$uid"
  group="$gid"
fi

chown "$user:$group" /var/www/html

if [ ! -e /var/www/html/config/application.php ]; then

  echo >&2 "Bedrock not found - downloading now..."

  cd /var/www
  composer create-project roots/bedrock html

  cd /var/www/html
  chown -R "$user:$group" .
fi

exec "$@"
