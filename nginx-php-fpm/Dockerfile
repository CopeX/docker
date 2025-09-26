# syntax=docker/dockerfile:1.7

ARG PHP_VERSION=8.3

########## Stage: node toolchain (cacheable) ##########
FROM node:18-bullseye AS node-tools
# Install your global CLIs here; cached independently from PHP base
# (If you need a different Node version, change the FROM tag)
RUN npm install -g \
      grunt-cli \
      clean-css-cli \
      grunt \
      grunt-critical \
      grunt-contrib-cssmin \
    && npm cache clean --force

########## Stage: final ##########
FROM copex/nginx-php-fpm:${PHP_VERSION}

EXPOSE 9000 9003
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND=noninteractive \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1

# APT + PHP xdebug in one shot, with BuildKit cache
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    set -eux; \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      software-properties-common ca-certificates curl wget git vim tmux \
      build-essential libsqlite3-dev iproute2 iputils-ping mysql-client \
      php${PHP_VERSION}-xdebug; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Bring in Node.js and the global npm packages from the node stage
# Copying /usr/local/{bin,lib} is enough for node/npm/npx + global modules
COPY --from=node-tools /usr/local/bin/node /usr/local/bin/node
COPY --from=node-tools /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node-tools /usr/local/bin/npx /usr/local/bin/npx
COPY --from=node-tools /usr/local/lib/node_modules /usr/local/lib/node_modules
# Ensure global modules are on PATH and node tools resolve correctly
ENV PATH="/usr/local/bin:/usr/local/lib/node_modules/.bin:${PATH}"

# Speed up subsequent npm operations inside the container (optional)
# (This only affects future npm runs in the container, not build time.)
ENV npm_config_cache=/var/www/.npm

# Cleanup
RUN set -eux; \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup; \
    mkdir -p /var/www/.npm /run/php; \
    chown -R 1000:33 /var/www/.npm; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Configure
COPY php-fpm/ext-xdebug.ini /etc/php/conf.d/21-xdebug.ini
COPY magento/local.xml.phpunit /var/www/htdocs/app/etc/local.xml.phpunit
COPY magento/phpunit.xml.dist /var/www/htdocs/phpunit.xml.dist
COPY php-fpm/php.ini /etc/php/php.ini
COPY php-fpm/php-fpm.conf /etc/php/www.conf

RUN set -eux; \
    ln -sf /etc/php/conf.d/21-xdebug.ini /etc/php/${PHP_VERSION}/fpm/conf.d/21-xdebug.ini; \
    rm -rf /etc/nginx/conf.d/includes/nginx/90-file-cache.conf; \
    userdel ubuntu || true; \
    usermod -u 1000 www-data
COPY init /etc/my_init.d
COPY nginx/site-templates/ /etc/nginx/site-templates/
