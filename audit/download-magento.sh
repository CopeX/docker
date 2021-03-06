#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "Please specify a Magento version number"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Please specify a destination"
    exit 1
fi

MAGE_VERSION=$1
DEST=$2
#MAGE_URL=https://github.com/OpenMage/magento-lts/archive/$MAGE_VERSION.tar.gz
MAGE_URL=https://github.com/speedupmate/Magento-CE-Mirror/archive/magento-ce-$MAGE_VERSION.tar.gz
echo "Downloading Magento " $MAGE_VERSION
echo $MAGE_URL

mkdir -p $DEST \
    && wget -qO- $MAGE_URL | tar -zxf- -C $DEST --strip=1 Magento-CE-Mirror-magento-ce-$MAGE_VERSION