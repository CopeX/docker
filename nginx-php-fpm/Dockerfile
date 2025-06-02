ARG PHP_VERSION=8.3
FROM copex/nginx-php-fpm:${PHP_VERSION}
ENV PHP_VERSION=${PHP_VERSION}

EXPOSE 9000 9003

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
    iputils-ping \
    # xdebug
    && apt-get --no-install-recommends -y install php${PHP_VERSION}-xdebug


#################################
# Node.js & Grunt CLI           #
#################################

ENV NVM_DIR="/usr/local/nvm"
ENV NODE_MAJOR=18
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1

RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    ln -s $NVM_DIR/nvm.sh /etc/profile.d/nvm.sh && \
    echo "source $NVM_DIR/nvm.sh" >> /etc/bash.bashrc && \
    echo "export NVM_DIR=\"$NVM_DIR\"" >> /etc/bash.bashrc && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"" >> /etc/bash.bashrc && \
    echo "[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"" >> /etc/bash.bashrc && \
    bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_MAJOR"


# Install global npm packages
RUN bash -c "source $NVM_DIR/nvm.sh && nvm use default && \
    ln -s \$(which node) /usr/bin/node && \
    ln -s \$(which npm) /usr/bin/npm && \
    ln -s \$(which npx) /usr/bin/npx && \
    npm install -g grunt-cli clean-css-cli grunt grunt-critical grunt-contrib-cssmin --unsafe-perm=true browser-sync livereload"



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

RUN mkdir -p "/var/www/.npm" && chown -R 1000:33 "/var/www/.npm"

# Configure
COPY php-fpm/ext-xdebug.ini /etc/php/conf.d/21-xdebug.ini


COPY magento/local.xml.phpunit /var/www/htdocs/app/etc/local.xml.phpunit
COPY magento/phpunit.xml.dist /var/www/htdocs/phpunit.xml.dist

# Copy php config (to override production config)
COPY php-fpm/php.ini /etc/php/php.ini
COPY php-fpm/php-fpm.conf /etc/php/www.conf

RUN ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/${PHP_VERSION}/fpm/conf.d/21-xdebug.ini \
    && rm -rf /etc/nginx/conf.d/includes/nginx/90-file-cache.conf

COPY init /etc/my_init.d

COPY nginx/site-templates/ /etc/nginx/site-templates/

RUN userdel ubuntu && usermod -u 1000 www-data
