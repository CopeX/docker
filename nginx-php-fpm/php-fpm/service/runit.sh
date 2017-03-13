#!/bin/sh
if [ -z "$PHP_VERSION" ]; then
    PHP_VERSION="5.6"
fi
sed -i -e "s/\/var\/run\/php5\.6-fpm\.sock/\/var\/run\/php$PHP_VERSION-fpm\.sock/" /etc/nginx/conf.d/includes/php/10-params.conf
`php-fpm$PHP_VERSION` -c /etc/php/$PHP_VERSION/fpm