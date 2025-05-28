FROM phusion/baseimage:noble-1.0.0

# Build argument for PHP version
ARG PHP_VERSION=8.3
ENV PHP_VERSION=${PHP_VERSION}

RUN locale-gen en_US.UTF-8 de_DE.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Build packages first
RUN export DEBIAN_FRONTEND=noninteractive \
    && echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get --no-install-recommends -y install \
        imagemagick \
        unzip \
        openssl \
        patch \
        git

# Install PHP packages based on PHP_VERSION
RUN apt-get --no-install-recommends -y install \
        php-redis \
        php${PHP_VERSION} \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-xsl \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-apcu \
        php${PHP_VERSION}-imap \
        php${PHP_VERSION}-imagick \
        $(if [ "${PHP_VERSION}" = "7.4" ]; then echo "php${PHP_VERSION}-ctype php${PHP_VERSION}-dom php${PHP_VERSION}-simplexml php${PHP_VERSION}-json php${PHP_VERSION}-iconv"; fi) \
        $(if [ "${PHP_VERSION}" != "7.4" ]; then echo "php${PHP_VERSION}-dom"; fi) \
        $(if [ "${PHP_VERSION}" = "8.3" ] || [ "${PHP_VERSION}" = "8.4" ]; then echo "php${PHP_VERSION}-redis"; fi)

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
    # symlink php config for the specific version
    && ln -sf /etc/php/php.ini /etc/php/${PHP_VERSION}/cli/php.ini \
    # Set the specific PHP version as default
    && ln -sf /usr/bin/php${PHP_VERSION} /etc/alternatives/php \
    && sed -i "s/exec/# exec/g" /etc/service/cron/run

COPY init /etc/my_init.d

WORKDIR /var/www/htdocs