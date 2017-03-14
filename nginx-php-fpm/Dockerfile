FROM copex/nginx-php-fpm

EXPOSE 1080 9000

CMD ["/sbin/my_init"]

# Install
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup  && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    apt-get --no-install-recommends -y --force-yes install mysql-client \
    vim \
    git \
    curl \
    wget \
    build-essential \
    tmux \
    gem \
    libsqlite3-dev \
    php5.6-dev \
    php7.1-dev \
    php5.6-xdebug \
    iproute2

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
# Ruby 2                        #
#################################
RUN apt-add-repository ppa:brightbox/ruby-ng && \
apt-get update && \
apt-get install ruby2.2 ruby2.2-dev -y --force-yes

#################################
# Mailcatcher                   #
#################################
RUN gem install mailcatcher --conservative --no-rdoc --no-ri

#################################
# Cleanup                       #
#################################
RUN apt-get autoremove -y && \
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY nginx/sites-templates/ /etc/nginx/sites-templates/
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Configure
COPY php-fpm/ext-xdebug.ini /etc/php/5.6/fpm/conf.d/21-xdebug.ini
COPY php-fpm/ext-mailcatcher.ini /etc/php/5.6/fpm/conf.d/22-mailcatcher.ini


# Make sure the volume mount point is empty
RUN rm -rf /var/www/*

COPY magento/local.xml.phpunit /var/www/htdocs/app/etc/local.xml.phpunit
COPY magento/phpunit.xml.dist /var/www/htdocs/phpunit.xml.dist

# Copy php config
COPY php-fpm/php.ini /etc/php/5.6/fpm/php.ini
COPY php-fpm/php.ini /etc/php/7.1/fpm/php.ini
COPY php-fpm/php-fpm.conf /etc/php/5.6/fpm/pool.d/www.conf
COPY php-fpm/php-fpm.conf /etc/php/7.1/fpm/pool.d/www.conf

COPY mailcatcher/mailcatcher.sh /etc/service/mailcatcher/run

RUN ln -s /etc/php/5.6/fpm/conf.d/22-mailcatcher.ini /etc/php/7.1/fpm/conf.d/22-mailcatcher.ini && \
    ln -s /etc/php/5.6/fpm/conf.d/21-xdebug.ini /etc/php/7.1/fpm/conf.d/21-xdebug.ini && \
    chmod +x /etc/service/mailcatcher/run



RUN usermod -u 1000 www-data