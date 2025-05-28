#!/bin/sh
if [ -z "$PHP_VERSION" ]; then
    PHP_VERSION="8.1"
fi
php-fpm$PHP_VERSION -c /etc/php/$PHP_VERSION/fpm
