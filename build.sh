#!/bin/bash

REPO=copex/php DOCKERFILE=php/Dockerfile CONTEXT=php ./build_type.sh

REPO=copex/nginx-php-fpm DOCKERFILE=nginx-php-fpm/Dockerfile CONTEXT=nginx-php-fpm ./build_type.sh
