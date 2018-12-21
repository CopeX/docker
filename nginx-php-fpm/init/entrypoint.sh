#!/bin/bash

set -eu


templates_dir="/etc/nginx/sites-templates"
outdir="/etc/nginx/conf.d"

function template_files() {
    find "${templates_dir}" \
        -mindepth 1 \
        -maxdepth 1 \
        -name '*.tmpl' \
        -print0
}

function non_template_files() {
    find "${templates_dir}" \
        -mindepth 1 \
        -maxdepth 1 \
        -not \
        -name '*.tmpl' \
        -print0
}

#clean
find "${outdir}" -maxdepth 1 -type f -exec rm -v {} \;

template_files | xargs -0 substitute-env-vars.sh "${outdir}"
non_template_files | xargs -0 -I{} ln -s {} "${outdir}"

if [ -z ${PHP_VERSION:-} ]; then
    PHP_VERSION="5.6"
fi
ln -sf /usr/bin/php$PHP_VERSION /etc/alternatives/php

echo "\n127.0.0.1 $DOMAIN" >> /etc/hosts

sed -i "s/hostname=.*/hostname$DOMAIN/g" /etc/ssmtp/ssmtp.conf