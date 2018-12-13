FROM composer/satis

ENV DEBIAN_FRONTEND noninteractive

RUN apk --no-cache add supervisor at

COPY bin/* /satis/bin/

ADD supervisor/ /etc/supervisor/

RUN touch /var/log/satis-cron.log \
	&& mkdir -p /var/log/supervisor/

ENTRYPOINT ["/satis/bin/docker-entrypoint.sh"]

CMD [""]