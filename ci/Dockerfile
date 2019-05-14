FROM copex/php

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        ruby \
        zip \
        unzip

RUN gem install capistrano -v 3.4.0 && \
    gem install capistrano-scm-gitcopy -v 0.1.5 && \
    gem install capistrano-magento2


RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');"

RUN /var/www/htdocs/composer.phar global require hirak/prestissimo