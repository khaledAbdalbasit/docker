#!/bin/sh
set -e

if [ -d /var/www/storage-init ]; then
    cp -an /var/www/storage-init/. /var/www/storage/
fi

exec "$@"
