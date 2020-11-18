FROM copex/php

EXPOSE 80 443

CMD ["/sbin/my_init"]

# Build packages first

COPY nginx/install/nginx.list /etc/apt/sources.list.d/nginx.list
COPY nginx/install/nginx_signing.key /etc/apt/nginx_signing.key
RUN rm -rf /etc/nginx/conf.d/* && \
    apt-key add /etc/apt/nginx_signing.key && \
    export DEBIAN_FRONTEND=noninteractive && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup  && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get update && \
    apt-get -y install nginx mysql-client wget ssmtp net-tools unzip

RUN wget --no-check-certificate https://raw.github.com/rupa/z/master/z.sh -O /usr/local/bin/z.sh && \
    cd /usr/local/src && \
    chmod +x /usr/local/bin/z.sh && \
    echo '. /usr/local/bin/z.sh' >> /root/.bashrc

# Cleanup
RUN apt-get clean && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    find /var/lib/apt/lists -mindepth 1 -delete -print && \
    find /tmp /var/tmp -mindepth 2 -delete

# Configure nginx to start as a service
COPY ./nginx/service/runit.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run && \
    rm -rf /build

#################################
# Node.js & Grunt CLI           #
#################################
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get --no-install-recommends -y install nodejs && \
    npm install -g grunt-cli && \
    npm install -g magepack

###############################
# magepack                    #
###############################
RUN apt-get -y install gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget && \
npm install -g magepack --unsafe-perm=true --allow-root

# Prepare configuration
COPY nginx/site-templates/ /etc/nginx/site-templates/
COPY nginx/includes/ /etc/nginx/conf.d/includes/
COPY nginx/ssl/ /etc/nginx/ssl/
COPY nginx/nginx.conf /etc/nginx/nginx.conf

COPY nginx/ssl/dhparams.pem /etc/ssl/private/

# Copy php config
COPY php-fpm/php-fpm.conf /etc/php/www.conf
RUN ln -sf /etc/php/www.conf /etc/php/5.6/fpm/pool.d/www.conf && \
    ln -sf /etc/php/www.conf /etc/php/7.0/fpm/pool.d/www.conf && \
    ln -sf /etc/php/www.conf /etc/php/7.1/fpm/pool.d/www.conf && \
    ln -sf /etc/php/www.conf /etc/php/7.2/fpm/pool.d/www.conf && \
    ln -sf /etc/php/www.conf /etc/php/7.3/fpm/pool.d/www.conf && \
    ln -sf /etc/php/www.conf /etc/php/7.4/fpm/pool.d/www.conf && \
    ln -sf /etc/php/www.conf /etc/php/8.0/fpm/pool.d/www.conf && \
    ln -sf /etc/php/php.ini /etc/php/5.6/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.0/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.1/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.2/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.3/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.4/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/8.0/fpm/php.ini

# Configure PHP-FPM to start as a service
COPY php-fpm/service/runit.sh /etc/service/php-fpm/run

# Copy custom init script
COPY bin/ /usr/sbin/
COPY init /etc/my_init.d
COPY logrotate/magento /etc/logrotate.d/magento

RUN chmod +x /etc/my_init.d/*.sh && \
    chmod +x /etc/service/php-fpm/run && \
    mkdir -p /run/php /var/log/nginx /var/www/.composer/cache && \
    chown -R www-data:www-data /var/www/.composer && \
    ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

