FROM copex/cron

ENV NODE_MAJOR=18

#################################
# Node.js    & crontab-ui       #
#################################
ENV NVM_DIR="/root/.nvm"

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash - \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
    && nvm install $NODE_MAJOR \
    && npm install -g crontab-ui


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