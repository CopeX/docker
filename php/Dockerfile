FROM phusion/baseimage:focal-1.2.0

RUN locale-gen en_US.UTF-8 de_DE.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Build packages first
RUN export DEBIAN_FRONTEND=noninteractive \
    && echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get --no-install-recommends -y install \
        imagemagick \
        unzip \
        php-redis \
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
        php7.3-imap \
        php7.3-imagick \
        php7.4 \
        php7.4-cli \
        php7.4-common \
        php7.4-bcmath \
        php7.4-ctype \
        php7.4-curl \
        php7.4-dom \
        php7.4-gd \
        php7.4-intl \
        php7.4-mbstring \
        php7.4-mysql \
        php7.4-simplexml \
        php7.4-soap \
        php7.4-xsl \
        php7.4-zip \
        php7.4-json \
        php7.4-iconv \
        php7.4-apcu \
        php7.4-imap \
        php7.4-imagick \
        php8.0 \
        php8.0-cli \
        php8.0-common \
        php8.0-bcmath \
        php8.0-curl \
        php8.0-gd \
        php8.0-intl \
        php8.0-mbstring \
        php8.0-mysql \
        php8.0-xml \
        php8.0-soap \
        php8.0-xsl \
        php8.0-zip \
        php8.0-apcu \
        php8.0-imap \
        php8.0-imagick \
        php8.1 \
        php8.1-cli \
        php8.1-common \
        php8.1-bcmath \
        php8.1-curl \
        php8.1-gd \
        php8.1-intl \
        php8.1-mbstring \
        php8.1-mysql \
        php8.1-xml \
        php8.1-soap \
        php8.1-xsl \
        php8.1-zip \
        php8.1-apcu \
        php8.1-imap \
        php8.1-imagick \
        php8.2 \
        php8.2-cli \
        php8.2-common \
        php8.2-bcmath \
        php8.2-curl \
        php8.2-gd \
        php8.2-intl \
        php8.2-mbstring \
        php8.2-mysql \
        php8.2-xml \
        php8.2-soap \
        php8.2-xsl \
        php8.2-zip \
        php8.2-apcu \
        php8.2-imap \
        php8.2-imagick \
        openssl \
        patch \
        git

# Copy php config
COPY php.ini /etc/php/php.ini

#Install composer
RUN  curl --show-error --silent https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer \
    # Cleanup
    && apt-get clean \
    && rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && find /var/lib/apt/lists -mindepth 1 -delete -print \
    && find /tmp /var/tmp -mindepth 2 -delete \
    && apt-get purge -y --auto-remove \
    # symlink php config
    && ln -sf /etc/php/php.ini /etc/php/7.3/cli/php.ini \
    && ln -sf /etc/php/php.ini /etc/php/7.4/cli/php.ini \
    && ln -sf /etc/php/php.ini /etc/php/8.0/cli/php.ini \
    && ln -sf /etc/php/php.ini /etc/php/8.1/cli/php.ini \
    && ln -sf /etc/php/php.ini /etc/php/8.2/cli/php.ini \
    #Setting default version to 8.1
    && ln -sf /usr/bin/php8.1 /etc/alternatives/php \
    && sed -i "s/exec/# exec/g" /etc/service/cron/run

COPY init /etc/my_init.d

WORKDIR /var/www/htdocs