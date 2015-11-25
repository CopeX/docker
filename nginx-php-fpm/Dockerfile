FROM phusion/baseimage

RUN rm -rf /etc/nginx/conf.d/*

# Build packages first

COPY nginx/nginx.list /etc/apt/sources.list.d/nginx.list
COPY nginx/nginx_signing.key /etc/apt/nginx_signing.key
RUN apt-key add /etc/apt/nginx_signing.key
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup  && \
    add-apt-repository -y ppa:ondrej/php5-5.6 && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get update && \
    apt-get --no-install-recommends -y --force-yes install nginx \
        php5-fpm \
        php5-mysql \
        php5-imagick \
        php5-mcrypt \
        php5-curl \
        php5-cli \
        php5-memcache \
        php5-intl \
        php5-gd \
        php5-xdebug \
        php5-redis \
        curl

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
COPY php-fpm/php.ini /etc/php5/fpm/php.ini
COPY php-fpm/php-fpm.conf /etc/php5/fpm/pool.d/www.conf

RUN usermod -u 1000 www-data

WORKDIR /var/www/htdocs

EXPOSE 80 443