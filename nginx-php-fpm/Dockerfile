FROM copex/nginx-php-fpm

EXPOSE 1080 9000 9003

CMD ["/sbin/my_init"]

# Install
RUN export DEBIAN_FRONTEND=noninteractive  \
    && echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get --no-install-recommends -y install mysql-client \
    vim \
    git \
    curl \
    wget \
    build-essential \
    tmux \
    gem \
    libsqlite3-dev \
    iproute2 \
    # xdebug
    && apt-get --no-install-recommends -y install php7.4-xdebug php8.0-xdebug php8.1-xdebug php8.2-xdebug php8.3-xdebug


#################################
# Node.js & Grunt CLI           #
#################################

ENV NVM_DIR="/root/.nvm"
ENV NODE_MAJOR=18
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash - \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
    && nvm install $NODE_MAJOR \
    && npm install -g grunt-cli \
    && npm install -g clean-css-cli grunt grunt-critical grunt-contrib-cssmin --unsafe-perm=true \
    #################################
    # Livereload & BrowserSync      #
    #################################
    && npm install -g browser-sync \
    && npm install -g livereload

#################################
# Cleanup                       #
#################################
RUN apt-get remove --purge --auto-remove -y \
    && apt-get autoclean \
    && apt-get clean  \
    && rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && find /var/lib/apt/lists -mindepth 1 -delete -print \
    && find /tmp /var/tmp -mindepth 2 -delete \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY mailcatcher/mailcatcher.sh /etc/service/mailcatcher/run

RUN mkdir -p "/var/www/.npm" && chown -R 1000:33 "/var/www/.npm"

# Configure
COPY php-fpm/ext-xdebug.ini /etc/php/conf.d/21-xdebug.ini


COPY magento/local.xml.phpunit /var/www/htdocs/app/etc/local.xml.phpunit
COPY magento/phpunit.xml.dist /var/www/htdocs/phpunit.xml.dist

# Copy php config (to override production config)
COPY php-fpm/php.ini /etc/php/php.ini
COPY php-fpm/php-fpm.conf /etc/php/www.conf

RUN ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.4/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/8.0/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/8.1/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/8.2/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/8.3/fpm/conf.d/21-xdebug.ini \
    && chmod +x /etc/service/mailcatcher/run \
    && rm -rf /etc/nginx/conf.d/includes/nginx/90-file-cache.conf

COPY init /etc/my_init.d

COPY nginx/site-templates/ /etc/nginx/site-templates/

RUN usermod -u 1000 www-data
