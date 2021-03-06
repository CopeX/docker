#!/bin/bash

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

if [[ -z ${MAGE_RUN_TYPE:-} ]]; then
    sed -i "s/set \$MAGE_RUN_TYPE \${MAGE_RUN_TYPE};/# set \$MAGE_RUN_TYPE '';/g" /etc/nginx/site-templates/default.conf.tmpl
fi

if [[ -z ${MAGE_RUN_CODE:-} ]]; then
    sed -i "s/set \$MAGE_RUN_CODE \${MAGE_RUN_CODE};/# set \$MAGE_RUN_CODE '';/g" /etc/nginx/site-templates/default.conf.tmpl
fi

if [[ -z ${HOST_MAPPING:-} ]]; then
read -d '' HOST_MAPPING <<- EOF
map \$http_host \$MAGE_RUN_CODE {
    default '';
}

map ""  \$MAGE_RUN_TYPE {
    default '';
}
EOF

fi

[[ -z ${MAGENTO_ROOT:-} ]] || sed -i "s!\$MAGENTO_ROOT!${MAGENTO_ROOT}!g" /etc/logrotate.d/magento

if [[ -z ${SSL_ON:-} ]]; then
    SSL_ON="0"
fi

if [[ "$SSL_ON" == "0" ]]; then
    sed -i "s/ http2 ssl/ http2/g" /etc/nginx/site-templates/default.conf.tmpl
    sed -i "s/ssl_certificate/# ssl_certificate/g" /etc/nginx/site-templates/default.conf.tmpl
fi

if [[ -f "/etc/nginx/.htpasswd" ]]; then
    if [[ "$MAGENTO_VERSION" == "1" ]]; then
      sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/conf.d/includes/default/10-locations.conf
    else
      sed -i "s/# auth_basic/auth_basic/g" /etc/nginx/site-templates/M$MAGENTO_VERSION/nginx.conf
    fi
fi

#clean
find "${outdir}" -maxdepth 1 -type f -exec rm {} \;

template_files | xargs -0 substitute-env-vars.sh "${outdir}"
non_template_files | xargs -0 -I{} ln -sf {} "${outdir}"

if [[ ! -f /etc/nginx/conf.d/map.conf ]]; then
  printf "%s" "$HOST_MAPPING" > /etc/nginx/conf.d/map.conf
fi

if [[ -z ${DOMAIN:-} ]]; then
        DOMAIN="localhost"
fi

if [[ ! $(grep '/etc/hosts' -e "$DOMAIN") ]]; then
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
    echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
fi