#!/bin/sh

# Configure PHP-FPM to start as a service
mkdir /etc/service/php-fpm
cp -a /build/php-fpm/runit.sh /etc/service/php-fpm/run
chmod +x /etc/service/php-fpm/run
php5enmod mcrypt

# Ensure the mode is correct on the unix socket
sed -i 's#;listen.mode = 0660#listen.mode = 0666#g' /etc/php5/fpm/pool.d/www.conf

# Disable xdebug by default
php5dismod xdebug