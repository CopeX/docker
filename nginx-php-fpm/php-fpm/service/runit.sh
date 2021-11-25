#!/bin/sh
if [ -z "$PHP_VERSION" ]; then
    PHP_VERSION="7.4"
fi
php-fpm$PHP_VERSION -c /etc/php/$PHP_VERSION/fpm
