#!/bin/bash
# Set OPCACHE_MODE
if [ -z ${OPCACHE_MODE:-} ]; then
    OPCACHE_MODE="PRODUCTION"
fi
if [[ "$SSL_ON" != "PRODUCTION" ]]; then
  sed -i "s/opcache.validate_timestamps=0/opcache.validate_timestamps=1/g" /etc/php/php.ini
fi
