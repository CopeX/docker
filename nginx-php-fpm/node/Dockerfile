FROM copex/nginx-php-fpm

#################################
# Node.js & Grunt CLI           #
#################################
ENV NVM_DIR="/root/.nvm"

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash - \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
    && nvm install 14 \
    && npm install -g grunt-cli \
    && npm install -g magepack --unsafe-perm=true --allow-root