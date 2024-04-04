#!/bin/bash

if [ -z ${XDEBUG_MODE:-} ]; then
    XDEBUG_MODE="off"
fi

if [ "$XDEBUG_MODE" = "off" ]; then
    rm -f /etc/php/$PHP_VERSION/fpm/conf.d/21-xdebug.ini
    rm -f /etc/php/$PHP_VERSION/cli/conf.d/21-xdebug.ini
fi

# Create no xdebug for get.php, ....
cp -r /etc/php/$PHP_VERSION /etc/php/$PHP_VERSION-noxdebug
rm -f /etc/php/$PHP_VERSION-noxdebug/fpm/conf.d/21-xdebug.ini
rm -f /etc/php/$PHP_VERSION-noxdebug/cli/conf.d/21-xdebug.ini
sed -i 's/php-fpm.sock/php-fpm-noxdebug.sock/g' /etc/php/$PHP_VERSION-noxdebug/fpm/pool.d/www.conf
sed -i "s/php$PHP_VERSION-fpm\.pid/php$PHP_VERSION-fpm-noxdebug\.pid/g" /etc/php/$PHP_VERSION-noxdebug/fpm/php-fpm.conf
sed -i "s/etc\/php\/$PHP_VERSION\/fpm\/pool\.d\/\*\.conf/etc\/php\/$PHP_VERSION-noxdebug\/fpm\/pool\.d\/\*\.conf/g" /etc/php/$PHP_VERSION-noxdebug/fpm/php-fpm.conf
mkdir -p /etc/service/php-fpm-noxdebug
cp /etc/service/php-fpm/run /etc/service/php-fpm-noxdebug/run && \
sed -i 's/php-fpm$PHP_VERSION -c \/etc\/php\/$PHP_VERSION\/fpm/PHP_INI_SCAN_DIR=\/etc\/php\/$PHP_VERSION-noxdebug\/fpm\/conf\.d\/ php-fpm$PHP_VERSION -c \/etc\/php\/$PHP_VERSION-noxdebug\/fpm -y \/etc\/php\/$PHP_VERSION-noxdebug\/fpm\/php-fpm\.conf/g' /etc/service/php-fpm-noxdebug/run
chmod +x /etc/service/php-fpm-noxdebug/run



if [ -z ${ENABLE_BLACKFIRE:-} ]; then
    ENABLE_BLACKFIRE="false"
fi

if [ "$ENABLE_BLACKFIRE" = "true" ]; then
    if [ ! -e /etc/php/$PHP_VERSION/mods-available/blackfire.ini ]; then
        downloadLink="https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${PHP_VERSION//.}"
        echo "Downloading blackfire for PHP $PHP_VERSION from $downloadLink"
        curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -L -s $downloadLink
        mkdir -p /tmp/blackfire
        tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire
        mv /tmp/blackfire/blackfire-*.so $(php$PHP_VERSION -r "echo ini_get('extension_dir');")/blackfire.so
        printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > /etc/php/$PHP_VERSION/mods-available/blackfire.ini
        ln -s /etc/php/$PHP_VERSION/mods-available/blackfire.ini /etc/php/$PHP_VERSION/cli/conf.d/30-blackfire.ini
        ln -s /etc/php/$PHP_VERSION/mods-available/blackfire.ini /etc/php/$PHP_VERSION/fpm/conf.d/30-blackfire.ini
        rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz
    fi
fi

echo "root=postmaster" > /etc/ssmtp/ssmtp.conf
echo "mailhub=localhost:1025" >> /etc/ssmtp/ssmtp.conf
echo "hostname=$DOMAIN" >> /etc/ssmtp/ssmtp.conf