#!/bin/bash
php artisan view:clear
php artisan route:clear
php artisan route:list
php artisan route:cache
php artisan config:clear
php artisan config:cache
php artisan queue:flush
php artisan queue:restart

php artisan optimize:clear
composer dumpautoload -o
#php artisan migrate --no-interaction --force

supervisord -c /etc/supervisor.d/supervisord.ini