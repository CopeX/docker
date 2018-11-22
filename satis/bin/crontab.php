<?php

echo rand(0,59)." ".rand(0,23)." * * * /satis/bin/build.sh >> /var/log/satis-cron.log 2>&1 ".PHP_EOL;
#echo "* * * * * /satis/bin/build.sh >> /var/log/satis-cron.log 2>&1 ".PHP_EOL;

$updateString = getenv('UPDATE_PERIOD') ? getenv('UPDATE_PERIOD') : "+6 month";
#$updateString = "+1 minute";
$date = strtotime($updateString);

echo date('i H d m', $date).' * echo "" | crontab -'.PHP_EOL;