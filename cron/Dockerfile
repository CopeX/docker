FROM copex/php

COPY cron.sh /etc/my_init.d/cron.sh
RUN chmod +x /etc/my_init.d/cron.sh

RUN sed -i "s/# exec/exec/g" /etc/service/cron/run