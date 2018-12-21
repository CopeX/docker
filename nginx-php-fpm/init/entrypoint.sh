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

if [ -z ${MAGENTO_VERSION:-} ]; then
    MAGENTO_VERSION="1"
fi

if [ "$MAGENTO_VERSION" = "2" ]; then
    if [ -e /etc/nginx/sites-templates/defaultM2.conf.tmpl ]; then
        mkdir /etc/nginx/sites-templates/M1
        mv /etc/nginx/sites-templates/default.conf.tmpl /etc/nginx/sites-templates/M1/default.conf.tmpl
        mv /etc/nginx/sites-templates/defaultM2.conf.tmpl /etc/nginx/sites-templates/default.conf.tmpl
    fi
fi

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


if [ -z ${PHP_ENABLE_XDEBUG:-} ]; then
    PHP_ENABLE_XDEBUG="true"
fi



# No Xdebug fpm
cp -r /etc/php/$PHP_VERSION /etc/php/$PHP_VERSION-noxdebug
rm -f /etc/php/$PHP_VERSION-noxdebug/fpm/conf.d/20-xdebug.ini
rm -f /etc/php/$PHP_VERSION-noxdebug/cli/conf.d/20-xdebug.ini
rm -f /etc/php/$PHP_VERSION-noxdebug/fpm/pool.d/www.conf
cp -f /etc/php/5.6/fpm/pool.d/www.conf /etc/php/$PHP_VERSION-noxdebug/fpm/pool.d/www.conf
sed -i 's/php-fpm.sock/php-fpm-noxdebug.sock/g' /etc/php/$PHP_VERSION-noxdebug/fpm/pool.d/www.conf
sed -i "s/php$PHP_VERSION-fpm\.pid/php$PHP_VERSION-fpm-noxdebug\.pid/g" /etc/php/$PHP_VERSION-noxdebug/fpm/php-fpm.conf
sed -i "s/etc\/php\/$PHP_VERSION\/fpm\/pool\.d\/\*\.conf/etc\/php\/$PHP_VERSION-noxdebug\/fpm\/pool\.d\/\*\.conf/g" /etc/php/$PHP_VERSION-noxdebug/fpm/php-fpm.conf
mkdir -p /etc/service/php-fpm-noxdebug
cp /etc/service/php-fpm/run /etc/service/php-fpm-noxdebug/run && \
sed -i 's/php-fpm$PHP_VERSION -c \/etc\/php\/$PHP_VERSION\/fpm/PHP_INI_SCAN_DIR=\/etc\/php\/$PHP_VERSION-noxdebug\/fpm\/conf\.d\/ php-fpm$PHP_VERSION -c \/etc\/php\/$PHP_VERSION-noxdebug\/fpm -y \/etc\/php\/$PHP_VERSION-noxdebug\/fpm\/php-fpm\.conf/g' /etc/service/php-fpm-noxdebug/run
chmod +x /etc/service/php-fpm-noxdebug/run


if [ "$PHP_ENABLE_XDEBUG" = "false" ]; then
    rm -f /etc/php/$PHP_VERSION/fpm/conf.d/20-xdebug.ini
    rm -f /etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini
fi

if [ -z ${ENABLE_BLACKFIRE:-} ]; then
    ENABLE_BLACKFIRE="false"
fi

if [ "$ENABLE_BLACKFIRE" = "true" ]; then
    php_versions=(5.6 7.0 7.1 7.2 7.3)
    for version in "${php_versions[@]}"
    do
        if [ ! -e /etc/php/$version/mods-available/blackfire.ini ]; then
            downloadLink="https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${version//.}"
            echo "Downloading blackfire for PHP $version from $downloadLink"
            curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -L -s $downloadLink
            mkdir -p /tmp/blackfire
            tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire
            mv /tmp/blackfire/blackfire-*.so $(php$version -r "echo ini_get('extension_dir');")/blackfire.so
            printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > /etc/php/$version/mods-available/blackfire.ini
            ln -s /etc/php/$version/mods-available/blackfire.ini /etc/php/$version/cli/conf.d/30-blackfire.ini
            ln -s /etc/php/$version/mods-available/blackfire.ini /etc/php/$version/fpm/conf.d/30-blackfire.ini
            rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz
        fi
    done
fi