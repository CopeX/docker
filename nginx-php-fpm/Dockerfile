ARG PHP_VERSION=8.3
FROM copex/php:${PHP_VERSION}

EXPOSE 80 443

CMD ["/sbin/my_init"]

COPY ./nginx/service/runit.sh /etc/service/nginx/run

RUN rm -rf /etc/nginx/conf.d/* \
    && export DEBIAN_FRONTEND=noninteractive \
    && echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && apt-get update \
    && apt-get -y install --no-install-recommends --no-install-suggests nginx mysql-client wget ssmtp net-tools unzip \
    && bash -euxo pipefail -c '\
      add_if_available(){ local p="$1"; if apt-cache policy "$p" | awk "/Candidate:/ {print \$2}" | grep -vq "(none)"; then PKGS+=("$p"); fi; }; \
      PKGS=(); \
      add_if_available "php'${PHP_VERSION}'-fpm"; \
      if [ "${#PKGS[@]}" -eq 0 ]; then echo "no php-fpm for '${PHP_VERSION}'" >&2; exit 1; fi; \
      apt-get install -y --no-install-recommends "${PKGS[@]}" \
    ' \
    && chmod +x /etc/service/nginx/run \
    && rm -rf /build

COPY nginx/site-templates/ /etc/nginx/site-templates/
COPY nginx/conf.d/includes/ /etc/nginx/conf.d/includes/
COPY nginx/ssl/ /etc/nginx/ssl/
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/ssl/dhparams.pem /etc/ssl/private/

COPY php-fpm/php-fpm.conf /etc/php/www.conf
RUN set -eux; \
    if [ -d "/etc/php/${PHP_VERSION}/fpm/pool.d" ]; then ln -sf /etc/php/www.conf "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"; fi; \
    if [ -d "/etc/php/${PHP_VERSION}/fpm" ]; then ln -sf /etc/php/php.ini "/etc/php/${PHP_VERSION}/fpm/php.ini"; fi

COPY php-fpm/service/runit.sh /etc/service/php-fpm/run

COPY bin/ /usr/sbin/
COPY init /etc/my_init.d
COPY logrotate/magento /etc/logrotate.d/magento

RUN chmod +x /etc/my_init.d/*.sh \
    && chmod +x /etc/service/php-fpm/run \
    && mkdir -p /run/php /var/log/nginx /var/www/.composer/cache \
    && chown -R www-data:www-data /var/www/.composer \
    && ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && apt-get remove --purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list \
    && apt-get clean \
    && rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && find /var/lib/apt/lists -mindepth 1 -delete -print \
    && find /tmp /var/tmp -mindepth 2 -delete
