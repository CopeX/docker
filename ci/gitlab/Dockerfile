FROM copex/php

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        openssh-client \
        zip \
        unzip \
        git apt-transport-https ca-certificates && \
    update-ca-certificates \
    # Cleanup
    && apt-get clean \
    && rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && find /var/lib/apt/lists -mindepth 1 -delete -print \
    && find /tmp /var/tmp -mindepth 2 -delete \
    && apt-get purge -y --auto-remove

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
     export NVM_DIR="$HOME/.nvm" &&  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install v18 && nvm use v18

# set git user
# For Docker builds disable host key checking. Be aware that by adding that
# you are suspectible to man-in-the-middle attacks.
# WARNING: Use this only with the Docker executor, if you use it with shell
# you will overwrite your user's SSH config.
RUN mkdir -p ~/.ssh && \
    echo "StrictHostKeyChecking no" >> $(find /etc -iname ssh_config) && \
    git config --global user.email "ci@copex.io" && git config --global user.name "CI Deployment"

RUN curl -LO https://github.com/deployphp/deployer/releases/download/v7.4.0/deployer.phar \
    && mv deployer.phar /usr/local/bin/dep \
    && chmod +x /usr/local/bin/dep

COPY ssh-deactivate-key-checking ssh-start-entrypoint ssh-add-known-host /bin/

ENV LC_ALL=en_US.UTF-8

ENTRYPOINT ["ssh-start-entrypoint"]