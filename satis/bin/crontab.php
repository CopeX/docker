<?php

$updateString = getenv('UPDATE_EXPIRES') ? getenv('UPDATE_EXPIRES') : "now";

$date = strtotime($updateString);
if ($date > time()) {
    echo rand(0,59)." ".rand(0,23)." * * * /satis/bin/build.sh >> /var/log/satis-cron.log 2>&1 ".PHP_EOL;
}
