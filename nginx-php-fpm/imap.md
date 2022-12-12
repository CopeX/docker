### Create imap image and tag

If you want to create a specific image e.g. want to install imap
just do the following

```
docker run -it copex/nginx-php-fpm bash
```

Inside the container execute 

```
apt-get update
apt-get install php7.2-imap php7.3-imap php7.4-imap php8.0-imap php8.1-imap php8.2-imap
phpenmod imap
apt-get clean && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    find /var/lib/apt/lists -mindepth 1 -delete -print && \
    find /tmp /var/tmp -mindepth 2 -delete
```

Then get container id by docker ps

and commit the container as image

```
docker commit CONTAINER_ID copex/nginx-php-fpm:imap
```

and push it to the repo

```
docker push copex/nginx-php-fpm:imap
```