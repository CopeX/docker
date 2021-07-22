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
    && apt-get --no-install-recommends -y install php-xdebug \
    #################################
    # Node.js & Grunt CLI           #
    #################################
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get --no-install-recommends --no-install-suggests -y install nodejs \
    && npm install -g grunt-cli \
    && npm install -g clean-css-cli grunt grunt-critical grunt-contrib-cssmin --unsafe-perm=true \
    ###############################
    # magepack                    #
    ###############################
    && apt-get --no-install-recommends --no-install-suggests -y install gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget \
    && npm install -g magepack --unsafe-perm=true --allow-root \
    ###############################
    # modman.phar                 #
    ###############################
    && git clone https://github.com/colinmollenhour/modman.git /usr/local/src/modman \
    && mv /usr/local/src/modman/modman /usr/local/bin/modman \
    && chmod +x /usr/local/bin/modman \
    #################################
    # Ruby 2                        #
    #################################
    && apt-get install --no-install-recommends --no-install-suggests ruby ruby-dev -y
    #################################
    # Mailcatcher                   #
    #################################
RUN gem install mailcatcher --conservative --no-document \
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

# Configure
COPY php-fpm/ext-xdebug.ini /etc/php/conf.d/21-xdebug.ini


COPY magento/local.xml.phpunit /var/www/htdocs/app/etc/local.xml.phpunit
COPY magento/phpunit.xml.dist /var/www/htdocs/phpunit.xml.dist

# Copy php config (to override production config)
COPY php-fpm/php.ini /etc/php/php.ini
COPY php-fpm/php-fpm.conf /etc/php/www.conf

RUN ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/5.6/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.0/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.1/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.2/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.3/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.4/fpm/conf.d/21-xdebug.ini \
    && ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/8.0/fpm/conf.d/21-xdebug.ini \
    && chmod +x /etc/service/mailcatcher/run \
    && rm -rf /etc/nginx/conf.d/includes/nginx/90-file-cache.conf

COPY init /etc/my_init.d

COPY nginx/site-templates/ /etc/nginx/site-templates/

RUN usermod -u 1000 www-data
