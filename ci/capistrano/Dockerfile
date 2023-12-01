FROM copex/php

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        ruby \
        zip \
        unzip \
        git

RUN gem install capistrano -v 3.4.0 && \
    gem install capistrano-scm-gitcopy -v 0.1.5 && \
    gem install capistrano-magento2 -v 0.8.7

RUN apt-get update && \
    apt-get install apt-transport-https ca-certificates -y && \
    update-ca-certificates