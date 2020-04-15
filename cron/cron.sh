#!/bin/sh

if [ -z ${MAGENTO_VERSION:-} ]; then
    MAGENTO_VERSION="1"
fi

if [ $MAGENTO_VERSION = 2 ]; then
    echo "* * * * * cd $MAGENTO_ROOT && php bin/magento cron:run | grep -v \"Ran jobs by schedule\" >> $MAGENTO_ROOT/var/log/cron_run.log" > mycron
else
    if [ -e $MAGENTO_ROOT/scheduler_cron.sh ]; then
        echo "* * * * * ! test -e $MAGENTO_ROOT/maintenance.flag && /bin/bash $MAGENTO_ROOT/scheduler_cron.sh --mode always" > mycron
        echo "* * * * * ! test -e $MAGENTO_ROOT/maintenance.flag && /bin/bash $MAGENTO_ROOT/scheduler_cron.sh --mode default" >> mycron
    else
        echo "* * * * * ! test -e $MAGENTO_ROOT/maintenance.flag && /bin/sh $MAGENTO_ROOT/cron.sh" > mycron
    fi
fi
crontab -u www-data mycron

rm mycron

## Disable realpath cache & set max execution time
sed -i "s/realpath_cache_size = 4M/realpath_cache_size = 0/g" /etc/php/php.ini
sed -i "s/max_execution_time = 90/max_execution_time = 0/g" /etc/php/php.ini

# Set memory limit
if [ -z ${MEMORY_LIMIT:-} ]; then
    MEMORY_LIMIT="512M"
fi

sed -i "s/memory_limit = 512M/memory_limit = $MEMORY_LIMIT/g" /etc/php/php.ini