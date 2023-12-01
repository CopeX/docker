FROM copex/php

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        openssh-client \
        zip \
        unzip \
        git

# set git user
# For Docker builds disable host key checking. Be aware that by adding that
# you are suspectible to man-in-the-middle attacks.
# WARNING: Use this only with the Docker executor, if you use it with shell
# you will overwrite your user's SSH config.
RUN mkdir -p ~/.ssh && \
    bash -c '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config' && \
    git config --global user.email "ci@copex.io" && git config --global user.name "CI Deployment"

RUN apt-get update && \
    apt-get install apt-transport-https ca-certificates -y && \
    update-ca-certificates \
    # Cleanup
    && apt-get clean \
    && rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && find /var/lib/apt/lists -mindepth 1 -delete -print \
    && find /tmp /var/tmp -mindepth 2 -delete \
    && apt-get purge -y --auto-remove \