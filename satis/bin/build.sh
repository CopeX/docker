#!/usr/bin/env bash

if [ -f /satis/config/satis.json ]; then
    mkdir -p /build
    cd /build
    /satis/bin/satis build /satis/config/satis.json
else
    echo "No satis config found"
fi