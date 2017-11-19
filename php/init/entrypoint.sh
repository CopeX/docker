#!/bin/bash
# Set PHP-Version
if [ -z ${PHP_VERSION:-} ]; then
    PHP_VERSION="5.6"
fi
ln -sf /usr/bin/php$PHP_VERSION /etc/alternatives/php
