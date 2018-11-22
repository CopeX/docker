#!/bin/bash
set -e

mkdir -p /root/.ssh

touch /root/.ssh/known_hosts

echo " >> Creating the correct known_hosts file"
for _DOMAIN in $PRIVATE_REPO_DOMAIN_LIST ; do
    IFS=':' read -a arr <<< "${_DOMAIN}"
    if [[ "${#arr[@]}" == "2" ]]; then
        port="${arr[1]}"
        ssh-keyscan -t rsa,dsa -p "${port}" ${arr[0]} >> /root/.ssh/known_hosts
    else
        ssh-keyscan -t rsa,dsa $_DOMAIN >> /root/.ssh/known_hosts
    fi
done
if [ ! -f /tmp/init ]; then
    echo "Initializing crontab"
    env UPDATE_PERIOD="$UPDATE_PERIOD" php /satis/bin/crontab.php | crontab -
    touch /tmp/init
fi
/satis/bin/build.sh

exec /usr/bin/supervisord -n -c/etc/supervisor/supervisord.conf