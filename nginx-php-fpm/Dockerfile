FROM copex/nginx-php-fpm

EXPOSE 1080 9000

CMD ["/sbin/my_init"]

# Install
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup  && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get --no-install-recommends -y install mysql-client \
    vim \
    git \
    curl \
    wget \
    build-essential \
    tmux \
    gem \
    libsqlite3-dev \
    iproute2

RUN apt-get --no-install-recommends -y install php-xdebug


###############################
# modman.phar                 #
###############################
RUN git clone https://github.com/colinmollenhour/modman.git /usr/local/src/modman && \
mv /usr/local/src/modman/modman /usr/local/bin/modman && \
chmod +x /usr/local/bin/modman

###############################
# composer.phar               #
###############################
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin && \
chmod +x /usr/local/bin/composer

#################################
#Parallell Downloads in Composer#
#################################
RUN composer global require hirak/prestissimo

#################################
# Ruby 2                        #
#################################
RUN apt-get install ruby ruby-dev -y

#################################
# Mailcatcher                   #
#################################
RUN gem install mailcatcher --conservative --no-rdoc --no-ri

#################################
# Livereload & BrowserSync      #
#################################
RUN npm install -g browser-sync && \
    npm install -g livereload

#################################
# Cleanup                       #
#################################
RUN apt-get autoremove -y && \
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY mailcatcher/mailcatcher.sh /etc/service/mailcatcher/run

# Configure
COPY php-fpm/ext-xdebug.ini /etc/php/conf.d/21-xdebug.ini


COPY magento/local.xml.phpunit /var/www/htdocs/app/etc/local.xml.phpunit
COPY magento/phpunit.xml.dist /var/www/htdocs/phpunit.xml.dist

# Copy php config (to override production config)
COPY php-fpm/php.ini /etc/php/php.ini
COPY php-fpm/php-fpm.conf /etc/php/www.conf

RUN ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/5.6/fpm/conf.d/21-xdebug.ini && \
    ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.0/fpm/conf.d/21-xdebug.ini && \
    ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.1/fpm/conf.d/21-xdebug.ini && \
    ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.2/fpm/conf.d/21-xdebug.ini && \
    ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.3/fpm/conf.d/21-xdebug.ini && \
    ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/7.4/fpm/conf.d/21-xdebug.ini && \
    ln -s /etc/php/conf.d/21-xdebug.ini /etc/php/8.0/fpm/conf.d/21-xdebug.ini && \
    chmod +x /etc/service/mailcatcher/run && \
    rm -rf /etc/nginx/conf.d/includes/nginx/90-file-cache.conf

COPY init /etc/my_init.d

COPY nginx/site-templates/ /etc/nginx/site-templates/

RUN usermod -u 1000 www-data
