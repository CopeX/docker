#!/bin/bash

if [[ "$CRON" == "true" ]]; then


  if [ -z "${CRON_EXPR:-}" ]; then
      CRON_EXPR="* * * * *"
  fi

  echo "$CRON_EXPR cd $MAGENTO_ROOT && php bin/magento cron:run | grep -v \"Ran jobs by schedule\" >> $MAGENTO_ROOT/var/log/cron_run.log" > mycron

  crontab -u www-data mycron
  rm mycron

  ## Disable realpath cache & set max execution time
  sed -i "s/realpath_cache_size = 4M/realpath_cache_size = 0/g" /etc/php/php.ini
  sed -i "s/max_execution_time = 90/max_execution_time = 0/g" /etc/php/php.ini

  # Set memory limit
  if [ -z ${MEMORY_LIMIT:-} ]; then
      MEMORY_LIMIT="512M"
  fi

  sed -i "s/memory_limit = 512M/memory_limit = $MEMORY_LIMIT/g" /etc/php/php.ini
  sed -i "s/# exec/exec/g" /etc/service/cron/run
fi