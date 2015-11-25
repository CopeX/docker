FROM phusion/baseimage

# Build packages first
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup  && \
    add-apt-repository -y ppa:ondrej/php5-5.6 && \
    apt-get update && \
    apt-get --no-install-recommends -y --force-yes install \
        php5-mysql \
        php5-imagick \
        php5-mcrypt \
        php5-curl \
        php5-cli \
        php5-memcache \
        php5-intl \
        php5-gd \
        php5-redis \
        curl

# Cleanup
RUN apt-get clean && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    find /var/lib/apt/lists -mindepth 1 -delete -print && \
    find /tmp /var/tmp -mindepth 2 -delete && \
    apt-get purge -y --auto-remove


# Copy php config
COPY php.ini /etc/php5/fpm/php.ini

RUN usermod -u 1000 www-data

RUN rm -rf /var/www/*

WORKDIR /var/www/htdocs