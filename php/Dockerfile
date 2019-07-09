FROM phusion/baseimage:0.11

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Build packages first
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup  && \
    add-apt-repository -y ppa:ondrej/php &&\
    apt-get update && \
    apt-get --no-install-recommends -y install \
        php5.6-fpm \
        php7.0-fpm \
        php7.1-fpm \
        php7.2-fpm \
        php7.3-fpm && \
    apt-get --no-install-recommends -y install \
        unzip \
        php-redis \
        php5.6 \
        php5.6-mysql \
        php5.6-imagick \
        php5.6-mcrypt \
        php5.6-curl \
        php5.6-cli \
        php5.6-memcache \
        php5.6-intl \
        php5.6-gd \
        php5.6-xsl \
        php5.6-intl \
        php5.6-zip \
        php5.6-mbstring \
        php5.6-soap \
        php5.6-apcu \
        curl \
        php7.0 \
        php7.0-cli \
        php7.0-common \
        php7.0-gd \
        php7.0-mysql \
        php7.0-curl \
        php7.0-int \
        php7.0-mcrypt \
        php7.0-tidy \
        php7.0-imap \
        php7.0-xsl \
        php7.0-mbstring \
        php7.0-bcmath \
        php7.0-xml \
        php7.0-zip \
        php7.0-soap \
        php7.0-apcu \
        php7.1 \
        php7.1-cli \
        php7.1-common \
        php7.1-gd \
        php7.1-mysql \
        php7.1-curl \
        php7.1-int \
        php7.1-mcrypt \
        php7.1-tidy \
        php7.1-imap \
        php7.1-xsl \
        php7.1-mbstring \
        php7.1-bcmath \
        php7.1-xml \
        php7.1-zip \
        php7.1-soap \
        php7.1-apcu \
        php7.2 \
        php7.2-cli \
        php7.2-common \
        php7.2-bcmath \
        php7.2-ctype \
        php7.2-curl \
        php7.2-dom \
        php7.2-gd \
        php7.2-intl \
        php7.2-mbstring \
        php7.2-mysql \
        php7.2-simplexml \
        php7.2-soap \
        php7.2-xsl \
        php7.2-zip \
        php7.2-json \
        php7.2-iconv \
        php7.2-apcu \
        php7.3 \
        php7.3-cli \
        php7.3-common \
        php7.3-bcmath \
        php7.3-ctype \
        php7.3-curl \
        php7.3-dom \
        php7.3-gd \
        php7.3-intl \
        php7.3-mbstring \
        php7.3-mysql \
        php7.3-simplexml \
        php7.3-soap \
        php7.3-xsl \
        php7.3-zip \
        php7.3-json \
        php7.3-iconv \
        php7.3-apcu \
        openssl \
        patch \
        git

#Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --filename=composer --install-dir=/usr/local/bin && \
    php -r "unlink('composer-setup.php');" && \
    composer global require hirak/prestissimo

# Cleanup
RUN apt-get clean && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    find /var/lib/apt/lists -mindepth 1 -delete -print && \
    find /tmp /var/tmp -mindepth 2 -delete && \
    apt-get purge -y --auto-remove

# Copy php config
COPY php.ini /etc/php/php.ini

COPY init /etc/my_init.d

RUN sed -i "s/exec/# exec/g" /etc/service/cron/run

WORKDIR /var/www/htdocs