#!/bin/sh

# Helpers
function json_print() {
  echo "{\"message\":\"$@\"}"
}

function wait_for_db() {

  dbaccess="denied"

  until [ $dbaccess = "success" ]; do
    json_print "Checking MySQL connection..."
    dbexist=$(mysql --host="${SS_DATABASE_SERVER}" --user="${SS_DATABASE_USERNAME}" --password="${SS_DATABASE_PASSWORD}" "${SS_DATABASE_NAME}"  -e exit 2>/dev/null; echo "$?")

    json_print "checking dbstatus "
    json_print $dbexist
    if [ $dbexist -eq 0 ]; then
      dbaccess="success"
      json_print "*** Ping database... OK ***"
      cd /var/www/website; php vendor/silverstripe/framework/cli-script.php dev/build | while read migration; do json_print "$migration"; done;
    else
      json_print "*** Waiting for DB ***"
      sleep 2
    fi
  done
}

# Docker IP
if [ -z "$DOCKER_HOST_IP" ]; then
    DOCKER_HOST_IP=$(ip route show 0.0.0.0/0 | grep -Eo 'via \S+' | awk '{ print $2 }')
fi


# XDebug
if [ -f /etc/php.d/xdebug.ini ]; then
sed -i 's/xdebug_server/'$DOCKER_HOST_IP'/' /etc/php.d/xdebug.ini
fi

#define correct localhost name for sendmail to use lines below taken from: http://stackoverflow.com/questions/26215021/configure-sendmail-inside-a-docker-container
line=$(head -n 1 /etc/hosts | awk '{printf "%s %s.localdomain %s", $1, $2, $2}')
export no_proxy=$no_proxy","$DOCKER_HOST_IP

wait_for_db &

json_print "Starting Apache service"
/usr/sbin/httpd -D FOREGROUND