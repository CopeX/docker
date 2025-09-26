FROM composer:2 AS composer

FROM phusion/baseimage:noble-1.0.2

RUN locale-gen en_US.UTF-8 de_DE.UTF-8
ARG PHP_VERSION=8.3

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 PHP_VERSION=${PHP_VERSION}

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    export DEBIAN_FRONTEND=noninteractive \
    && echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common ca-certificates curl gnupg \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends imagemagick unzip openssl patch git

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
    bash -euxo pipefail <<'EOF'
add_if_available() {
  local pkg="$1"
  if apt-cache policy "$pkg" | awk '/Candidate:/ {print $2}' | grep -vq '(none)'; then
    echo "will install: $pkg"
    PHP_PKGS+=("$pkg")
  else
    echo "skip (no candidate): $pkg"
  fi
}

PHP_VERSION="${PHP_VERSION:-8.3}"
PHP="php${PHP_VERSION}"
PHP_PKGS=()

add_if_available "${PHP}"
add_if_available "${PHP}-cli"
add_if_available "${PHP}-common"

add_if_available "${PHP}-bcmath"
add_if_available "${PHP}-curl"
add_if_available "${PHP}-gd"
add_if_available "${PHP}-intl"
add_if_available "${PHP}-mbstring"
add_if_available "${PHP}-mysql"
add_if_available "${PHP}-xml"
add_if_available "${PHP}-soap"
add_if_available "${PHP}-xsl"
add_if_available "${PHP}-zip"
add_if_available "${PHP}-imap"
add_if_available "${PHP}-imagick"
add_if_available "${PHP}-apcu"
add_if_available "${PHP}-redis"

# Nur falls es wirklich noch separat paketiert ist (meist nur 7.4)
add_if_available "${PHP}-json"
add_if_available "${PHP}-iconv"
add_if_available "${PHP}-dom"
add_if_available "${PHP}-simplexml"

# Fallback für redis, falls kein versionsspezifisches Paket einen Kandidaten hat
if apt-cache policy "${PHP}-redis" | awk '/Candidate:/ {print $2}' | grep -q '(none)'; then
  add_if_available "php-redis"
fi

if [ "${#PHP_PKGS[@]}" -eq 0 ]; then
  echo "No PHP packages found for ${PHP_VERSION}" >&2
  exit 1
fi

apt-get install -y --no-install-recommends "${PHP_PKGS[@]}"
EOF

COPY php.ini /etc/php/php.ini

RUN set -eux; if [ -d "/etc/php/${PHP_VERSION}/cli" ]; then ln -sf /etc/php/php.ini "/etc/php/${PHP_VERSION}/cli/php.ini"; fi

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN set -eux; \
    apt-get clean; \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup; \
    find /var/lib/apt/lists -mindepth 1 -delete -print; \
    find /tmp /var/tmp -mindepth 2 -delete; \
    apt-get purge -y --auto-remove; \
    if command -v update-alternatives >/dev/null 2>&1 && [ -x "/usr/bin/php${PHP_VERSION}" ]; then \
        update-alternatives --set php "/usr/bin/php${PHP_VERSION}" || true; \
    else \
        ln -sf "/usr/bin/php${PHP_VERSION}" /etc/alternatives/php || true; \
    fi; \
    sed -i "s/exec/# exec/g" /etc/service/cron/run || true; \
    mkdir -p /usr/share/locale; \
    for loc in en_US de_DE; do mkdir -p "/usr/share/locale/${loc}"; done

COPY init /etc/my_init.d

WORKDIR /var/www/htdocs
