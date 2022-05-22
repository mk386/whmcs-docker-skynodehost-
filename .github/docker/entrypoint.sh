#!/bin/ash -e
cd /app

mkdir -p /var/log/supervisord/ /var/log/nginx/ /var/log/php7/

# whmcs modules
git clone https://$GITHUB_USER:$GITHUB_TOKEN@github.com/skynodehost/SNPtero.git modules/servers/snptero
chown -R nginx:nginx .

## start cronjobs for the queue
echo -e "Starting cron jobs."
crond -L /var/log/crond -l 5

echo -e "Starting supervisord."
exec "$@"