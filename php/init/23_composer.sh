#!/bin/bash

export COMPOSER_HOME=/var/www/.composer/
if [[ -z ${COMPOSER:-} ]]; then
    COMPOSER="2"
fi

if [[ "$COMPOSER" == "1" ]]; then
    composer selfupdate --1
fi