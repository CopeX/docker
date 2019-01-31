FROM copex/cron

#################################
# Node.js    & crontab-ui       #
#################################
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt --no-install-recommends -y install sudo nodejs && \
    npm install -g crontab-ui


#################################
# Cleanup                       #
#################################
RUN apt-get autoremove -y && \
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure PHP-FPM to start as a service
COPY ./service/runit.sh /etc/service/crontab-ui/run

RUN chmod g+w -R  /usr/lib/node_modules/crontab-ui && \
    chgrp www-data -R  /usr/lib/node_modules/crontab-ui

ENV HOST 0.0.0.0
ENV PORT 8282

EXPOSE 8282