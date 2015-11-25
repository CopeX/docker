#!/bin/sh

if [ $USE_OLD_CRON ]; then
    echo "* * * * * ! test -e /var/www/htdocs/maintenance.flag && /bin/sh /var/www/htdocs/cron.sh" > mycron
else
    echo "* * * * * ! test -e /var/www/htdocs/maintenance.flag && /bin/bash /var/www/htdocs/scheduler_cron.sh --mode always" > mycron
    echo "* * * * * ! test -e /var/www/htdocs/maintenance.flag && /bin/bash /var/www/htdocs/scheduler_cron.sh --mode default" >> mycron
fi

crontab -u www-data mycron

rm mycron