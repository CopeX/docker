#!/bin/bash

# Set memory limit
if [[ -z ${MEMORY_LIMIT} ]]; then
    sed -i "s/memory_limit = 512M/memory_limit = $MEMORY_LIMIT/g" /etc/php/php.ini
fi