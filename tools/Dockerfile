FROM copex/php


# Install magerun
RUN export DEBIAN_FRONTEND=noninteractive && \
    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/02apt-speedup  && \
    apt-get update && \
    apt-get --no-install-recommends -y install mysql-client git vim wget && \
    curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin && \
    wget https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar && \
	chmod +x n98-magerun.phar && \
	mv n98-magerun.phar /usr/local/bin/n98-magerun  && \
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    wget https://phar.phpunit.de/phploc.phar && \
    chmod +x phploc.phar && \
    mv phploc.phar /usr/local/bin/phploc && \
    wget http://static.pdepend.org/php/latest/pdepend.phar && \
	chmod +x pdepend.phar && \
	mv pdepend.phar /usr/local/bin/pdepend && \
    wget http://static.phpmd.org/php/latest/phpmd.phar && \
	chmod +x phpmd.phar && \
	mv phpmd.phar /usr/local/bin/phpmd && \
    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && \
	chmod +x phpcs.phar && \
	mv phpcs.phar /usr/local/bin/phpcs && \
    wget https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar && \
	chmod +x phpcbf.phar && \
	mv phpcbf.phar /usr/local/bin/phpcbf && \
    wget https://phar.phpunit.de/phpcpd.phar && \
	chmod +x phpcpd.phar && \
	mv phpcpd.phar /usr/local/bin/phpcpd && \
    wget https://phar.phpunit.de/phpdcd.phar && \
	chmod +x phpdcd.phar && \
	mv phpdcd.phar /usr/local/bin/phpdcd && \
	wget https://github.com/Halleck45/PhpMetrics/raw/master/build/phpmetrics.phar && \
	chmod +x phpmetrics.phar && \
	mv phpmetrics.phar /usr/local/bin/phpmetrics && \
	wget http://get.sensiolabs.org/php-cs-fixer.phar && \
	chmod +x php-cs-fixer.phar && \
	mv php-cs-fixer.phar /usr/local/bin/php-cs-fixer

COPY bin/run.sh /bin/run.sh
RUN chmod +x /bin/run.sh

WORKDIR /var/www/htdocs

CMD /bin/run.sh