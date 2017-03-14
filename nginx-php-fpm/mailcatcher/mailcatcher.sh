#!/bin/sh

IP_ADDR=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
mailcatcher -f --http-port 1080 --http-ip $IP_ADDR >> /var/log/syslog
return 0