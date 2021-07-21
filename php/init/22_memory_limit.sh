#!/bin/bash

# Set memory limit
if [[ -n "${MEMORY_LIMIT}" ]]; then
    sed -i "s/memory_limit = .*/memory_limit = $MEMORY_LIMIT/g" /etc/php/php.ini
fi