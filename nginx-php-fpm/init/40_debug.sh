#!/bin/bash

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



if [ -z ${PHP_ENABLE_XDEBUG:-} ]; then
    PHP_ENABLE_XDEBUG="true"
fi


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