#!/bin/sh

# Configure nginx to start as a service
mkdir /etc/service/nginx
cp -a /build/nginx/runit.sh /etc/service/nginx/run
chmod +x /etc/service/nginx/run
