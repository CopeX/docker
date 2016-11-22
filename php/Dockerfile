FROM phusion/baseimage

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Build packages first
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup  && \
    add-apt-repository -y ppa:ondrej/php &&\
    apt-get update && \
    apt-get --no-install-recommends -y --force-yes install \
        php5.6 \
        php5.6-mysql \
        php5.6-imagick \
        php5.6-mcrypt \
        php5.6-curl \
        php5.6-cli \
        php5.6-memcache \
        php5.6-intl \
        php5.6-gd \
        php5.6-redis \
        php5.6-xsl \
        php5.6-intl \
        curl

# Cleanup
RUN apt-get clean && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    find /var/lib/apt/lists -mindepth 1 -delete -print && \
    find /tmp /var/tmp -mindepth 2 -delete && \
    apt-get purge -y --auto-remove


# Copy php config
COPY php.ini /etc/php/5.6/fpm/php.ini

WORKDIR /var/www/htdocs