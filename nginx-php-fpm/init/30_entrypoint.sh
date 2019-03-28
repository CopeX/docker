#!/bin/bash

set -eu


templates_dir="/etc/nginx/site-templates"
outdir="/etc/nginx/conf.d"

function template_files() {
    find "${templates_dir}" \
        -mindepth 1 \
        -maxdepth 1 \
        -name '*.tmpl' \
        -print0
}

function non_template_files() {
    find "${templates_dir}" \
        -mindepth 1 \
        -maxdepth 1 \
        -not \
        -name '*.tmpl' \
        -print0
}

if [[ -z ${MAGENTO_VERSION:-} ]]; then
    MAGENTO_VERSION="1"
fi

cp /etc/nginx/site-templates/M$MAGENTO_VERSION/default.conf.tmpl /etc/nginx/site-templates/default.conf.tmpl

if [[ -z ${SSL_ON:-} ]]; then
    SSL_ON="0"
fi

if [[ "$SSL_ON" == "0" ]]; then
    sed -i "s/ http2 ssl/ http2/g" /etc/nginx/site-templates/default.conf.tmpl
    sed -i "s/ssl_certificate/# ssl_certificate/g" /etc/nginx/site-templates/default.conf.tmpl
fi

if [[ -z ${PAGESPEED:-} ]]; then
    PAGESPEED="0"
fi

if [[ "$PAGESPEED" == "1" ]]; then
    if [[ -z ${TLD:-} ]]; then
        domain=${DOMAIN}
    else
        domain="*.${TLD}"
    fi
    sed -i "s/pagespeed Domain \*;/pagespeed Domain ${domain};/g" /etc/nginx/site-templates/M$MAGENTO_VERSION/pagespeed.conf.disabled
    ln -s /etc/nginx/site-templates/M$MAGENTO_VERSION/pagespeed.conf.disabled /etc/nginx/site-templates/M$MAGENTO_VERSION/pagespeed.conf
fi

if [[ -f "/etc/nginx/.htpasswd" ]]; then
    sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/site-templates/M2/nginx.conf
fi

#clean
find "${outdir}" -maxdepth 1 -type f -exec rm -v {} \;

template_files | xargs -0 substitute-env-vars.sh "${outdir}"
non_template_files | xargs -0 -I{} ln -sf {} "${outdir}"

if [[ -z ${PHP_VERSION:-} ]]; then
    PHP_VERSION="5.6"
fi
ln -sf /usr/bin/php$PHP_VERSION /etc/alternatives/php

if [[ ! $(grep '/etc/hosts' -e $DOMAIN) ]]; then
    echo "127.0.0.1 $DOMAIN" >> /etc/hosts
fi

if [[ ! $(grep '/etc/ssmtp/ssmtp.conf' -e 'AuthUser') ]]; then

    if [[ -z ${SSMTP_USER:-} ]]; then
        SSMTP_USER="copex"
    fi

    if [[ -z ${SSMTP_PASS:-} ]]; then
        SSMTP_PASS="xepoc"
    fi

    if [[ -z ${SSMTP_LOGIN_METHOD:-} ]]; then
        SSMTP_LOGIN_METHOD="LOGIN"
    fi

    sed -i "s/hostname=.*/hostname=$DOMAIN/g" /etc/ssmtp/ssmtp.conf
    echo "AuthUser=$SSMTP_USER" >> /etc/ssmtp/ssmtp.conf
    echo "AuthPass=$SSMTP_PASS" >> /etc/ssmtp/ssmtp.conf
    echo "AuthMethod=$SSMTP_LOGIN_METHOD" >> /etc/ssmtp/ssmtp.conf
fi