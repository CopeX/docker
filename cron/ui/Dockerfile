FROM copex/cron

ENV NODE_MAJOR=18

#################################
# Node.js    & crontab-ui       #
#################################
ENV NVM_DIR="/var/www/.nvm"
USER root
RUN mkdir $NVM_DIR /var/www/.npm && chown www-data:www-data $NVM_DIR /var/www/.npm
USER www-data

SHELL ["/bin/bash", "--login", "-c"]

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash - \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
    && nvm install $NODE_MAJOR \
    && npm install -g crontab-ui

#RUN ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/node" "/usr/local/bin/node" && \
#    ln -s "$NVM_DIR/versions/node/$(nvm version)/bin/npm" "/usr/local/bin/npm" \

USER www-data
# Configure crontab ui to start as a service
COPY ./service/runit.sh /etc/service/crontab-ui/run

#RUN chmod g+w -R  "$NVM_DIR/versions/node/$(nvm version)/lib/node_modules" && \
#    chgrp www-data -R "$NVM_DIR/versions/node/$(nvm version)/lib/node_modules"

ENV HOST 0.0.0.0
ENV PORT 8282

EXPOSE 8282
