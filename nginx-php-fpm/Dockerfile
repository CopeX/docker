FROM copex/nginx-php-fpm


# Install magerun
RUN apt-get update && \
    apt-get --no-install-recommends -y --force-yes install mysql-client php5-xdebug && \
    curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin && \
    apt-get install -y build-essential rubygems-integration ruby-dev libsqlite3-dev && \
    gem install mailcatcher --no-ri --no-rdoc && \
    apt-get remove -y build-essential && \
    apt-get autoremove -y && \
    apt-get remove --purge -y build-essential ruby-dev  rubygems-integration  libsqlite3-dev && apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY sites-templates/ /etc/nginx/sites-templates/

# Configure
COPY php-fpm/ext-xdebug.ini /etc/php5/fpm/conf.d/21-xdebug.ini
COPY php-fpm/ext-mailcatcher.ini /etc/php5/fpm/conf.d/22-mailcatcher.ini

# Make sure the volume mount point is empty
RUN rm -rf /var/www/*

COPY php-fpm/local.xml.phpunit /var/www/htdocs/app/etc/local.xml.phpunit

# Copy php config
COPY php-fpm/php.ini /etc/php5/fpm/php.ini
COPY php-fpm/php-fpm.conf /etc/php5/fpm/pool.d/www.conf

EXPOSE 1080 9000

CMD ["sh", "-c", "/usr/bin/env $(which mailcatcher) --ip=0.0.0.0 -f > /dev/null 2>&1 & /sbin/my_init"]