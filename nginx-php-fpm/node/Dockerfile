FROM copex/nginx-php-fpm

#################################
# Node.js & Grunt CLI           #
#################################
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get update \
    && apt-get --no-install-recommends --no-install-suggests -y install nodejs \
    && npm install -g grunt-cli \
    && npm install -g magepack --unsafe-perm=true --allow-root \
    && apt-get remove --purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list \
    && apt-get clean \
    && rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && find /var/lib/apt/lists -mindepth 1 -delete -print \
    && find /tmp /var/tmp -mindepth 2 -delete