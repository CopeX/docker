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

if [ -z ${PHP_ENABLE_XDEBUG:-} ]; then
    PHP_ENABLE_XDEBUG="true"
fi


# No Xdebug fpm
cp -r /etc/php/$PHP_VERSION /etc/php/$PHP_VERSION-noxdebug
rm /etc/php/$PHP_VERSION-noxdebug/fpm/conf.d/20-xdebug.ini
rm /etc/php/$PHP_VERSION-noxdebug/cli/conf.d/20-xdebug.ini
rm /etc/php/$PHP_VERSION-noxdebug/fpm/pool.d/www.conf
cp -f /etc/php/5.6/fpm/pool.d/www.conf /etc/php/$PHP_VERSION-noxdebug/fpm/pool.d/www.conf
sed -i 's/php-fpm.sock/php-fpm-noxdebug.sock/g' /etc/php/$PHP_VERSION-noxdebug/fpm/pool.d/www.conf
sed -i "s/php$PHP_VERSION-fpm\.pid/php$PHP_VERSION-fpm-noxdebug\.pid/g" /etc/php/$PHP_VERSION-noxdebug/fpm/php-fpm.conf
sed -i "s/etc\/php\/$PHP_VERSION\/fpm\/pool\.d\/\*\.conf/etc\/php\/$PHP_VERSION-noxdebug\/fpm\/pool\.d\/\*\.conf/g" /etc/php/$PHP_VERSION-noxdebug/fpm/php-fpm.conf
mkdir -p /etc/service/php-fpm-noxdebug
cp /etc/service/php-fpm/run /etc/service/php-fpm-noxdebug/run && \
sed -i 's/php-fpm$PHP_VERSION -c \/etc\/php\/$PHP_VERSION\/fpm/PHP_INI_SCAN_DIR=\/etc\/php\/$PHP_VERSION-noxdebug\/fpm\/conf\.d\/ php-fpm$PHP_VERSION -c \/etc\/php\/$PHP_VERSION-noxdebug\/fpm -y \/etc\/php\/$PHP_VERSION-noxdebug\/fpm\/php-fpm\.conf/g' /etc/service/php-fpm-noxdebug/run
chmod +x /etc/service/php-fpm-noxdebug/run


if [ "$PHP_ENABLE_XDEBUG" = "false" ]; then
    rm /etc/php/$PHP_VERSION/fpm/conf.d/20-xdebug.ini
    rm /etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini
fi
