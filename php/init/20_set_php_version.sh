#!/bin/bash

ln -sf /etc/php/php.ini /etc/php/5.6/cli/php.ini && \
ln -sf /etc/php/php.ini /etc/php/7.0/cli/php.ini && \
ln -sf /etc/php/php.ini /etc/php/7.1/cli/php.ini && \
ln -sf /etc/php/php.ini /etc/php/7.2/cli/php.ini && \
ln -sf /etc/php/php.ini /etc/php/7.3/cli/php.ini

# Set PHP-Version
if [ -z ${PHP_VERSION:-} ]; then
    PHP_VERSION="5.6"
fi
ln -sf /usr/bin/php$PHP_VERSION /etc/alternatives/php
