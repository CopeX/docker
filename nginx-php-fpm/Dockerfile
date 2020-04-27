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
    apt-get upgrade -y && \
    apt-get -y install mysql-client wget ssmtp net-tools && \
    apt-get -y install build-essential zlib1g-dev libpcre3 libpcre3-dev libssl-dev unzip sudo brotli git
RUN wget --no-check-certificate https://raw.github.com/rupa/z/master/z.sh -O /usr/local/bin/z.sh && \
    cd /usr/local/src && \
    git clone --recursive https://github.com/google/ngx_brotli.git && \
    chmod +x /usr/local/bin/z.sh && \
    echo '. /usr/local/bin/z.sh' >> /root/.bashrc

RUN wget --no-check-certificate https://ngxpagespeed.com/install && \
    chmod +x install && \
    ./install  --nginx-version latest  -a '--conf-path=/etc/nginx/nginx.conf --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-http_v2_module --add-module=/usr/local/src/ngx_brotli' && \
    rm install

# Cleanup
RUN apt-get clean && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    find /var/lib/apt/lists -mindepth 1 -delete -print && \
    find /tmp /var/tmp -mindepth 2 -delete && \
    apt-get purge -y --auto-remove build-essential zlib1g-dev libssl-dev libpcre3-dev git

# Configure nginx to start as a service
COPY ./nginx/service/runit.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run && \
    rm -rf /build

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
    ln -sf /etc/php/php.ini /etc/php/5.6/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.0/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.1/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.2/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.3/fpm/php.ini && \
    ln -sf /etc/php/php.ini /etc/php/7.4/fpm/php.ini

# Configure PHP-FPM to start as a service
COPY php-fpm/service/runit.sh /etc/service/php-fpm/run

# Copy custom init script
COPY bin/ /usr/sbin/
COPY init /etc/my_init.d

RUN chmod +x /etc/my_init.d/*.sh && \
    chmod +x /etc/service/php-fpm/run && \
    mkdir -p /run/php /var/log/nginx /var/cache/pagespeed /var/www/.composer/cache && \
    chown -R www-data:www-data /var/www/.composer /var/cache/pagespeed && \
    ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

