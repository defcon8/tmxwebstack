#!/bin/bash
mkdir /tmxweb/tmp
chown -R www-data:www-data /tmxweb/tmp
/etc/init.d/php7.1-fpm start
nginx -g "daemon off;"