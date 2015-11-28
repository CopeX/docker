FROM copex/php

RUN rm -rf /etc/nginx/conf.d/*

# Build packages first

COPY nginx/nginx.list /etc/apt/sources.list.d/nginx.list
COPY nginx/nginx_signing.key /etc/apt/nginx_signing.key
RUN apt-key add /etc/apt/nginx_signing.key
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup  && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get update && \
    apt-get --no-install-recommends -y --force-yes install nginx php5-fpm

# Cleanup
RUN apt-get clean && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    find /var/lib/apt/lists -mindepth 1 -delete -print && \
    find /tmp /var/tmp -mindepth 2 -delete && \
    apt-get purge -y --auto-remove

# Setup nginx service
COPY ./nginx/*.sh /build/nginx/
RUN /build/nginx/setup.sh


# Setup php-fpm service
COPY ./php-fpm/*.sh /build/php-fpm/
RUN /build/php-fpm/setup.sh

RUN rm -rf /build

# Copy custom init script
COPY bin/ /usr/sbin/
COPY init /etc/my_init.d

# Prepare configuration
COPY nginx/sites-templates/ /etc/nginx/sites-templates/
COPY nginx/includes/ /etc/nginx/conf.d/includes/
COPY nginx/ssl/ /etc/nginx/ssl/
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy php config
COPY php-fpm/php-fpm.conf /etc/php5/fpm/pool.d/www.conf

EXPOSE 80 443

CMD ["/sbin/my_init"]