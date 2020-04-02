#!/bin/sh

if [ -z ${MAGENTO_VERSION:-} ]; then
    MAGENTO_VERSION="1"
fi

if [ $MAGENTO_VERSION = 2 ]; then
    echo "* * * * * php $MAGENTO_ROOT/bin/magento cron:run | grep -v Ran jobs by schedule >> $MAGENTO_ROOT/var/log/cron_run.log" > mycron
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