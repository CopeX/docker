#!/bin/sh
if [ -z "$PHP_VERSION" ]; then
    PHP_VERSION="5.6"
fi
`php-fpm$PHP_VERSION` -c /etc/php/$PHP_VERSION/fpm
ln -sf `/usr/bin/php$PHP_VERSION` /etc/alternatives/php