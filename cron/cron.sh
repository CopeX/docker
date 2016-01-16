#!/bin/sh

if [ -e $MAGENTO_ROOT/scheduler_cron.sh ]; then
    echo "* * * * * ! test -e $MAGENTO_ROOT/maintenance.flag && /bin/bash $MAGENTO_ROOT/scheduler_cron.sh --mode always" > mycron
    echo "* * * * * ! test -e $MAGENTO_ROOT/maintenance.flag && /bin/bash $MAGENTO_ROOT/scheduler_cron.sh --mode default" >> mycron
else
    echo "* * * * * ! test -e $MAGENTO_ROOT/maintenance.flag && /bin/sh $MAGENTO_ROOT/cron.sh" > mycron
fi

crontab -u www-data mycron

rm mycron