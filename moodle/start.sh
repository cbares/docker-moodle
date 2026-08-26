#!/bin/bash
set -e
set -u

if [ -z "$HTTPS_PORT" ]; then
  HTTPS_PORT=:443
fi
CHTTPS_PORT=:$HTTPS_PORT


if [ ! -f /var/www/html/config.php ]; then
  sleep 10s
  sed -e "s/pgsql/mysqli/
  s/localhost/mysql/
  s/username/moodle/
  s/password/$MOODLE_PASSWORD/
  s/http:\/\/example.com\/moodle/https:\/\/$VIRTUAL_HOST$CHTTPS_PORT/
  s/\/var\/www\/html\/moodle/\/var\/www\/html\//
  s/\/home\/example\/moodledata/\/var\/moodledata/" /var/www/html/config-dist.php > /var/www/html/config.php

  chown www-data:www-data /var/www/html/config.php
fi



chown www-data: /var/moodledata -R

sed -i "s/::VIRTUAL_HOST::/$VIRTUAL_HOST/g" /etc/apache2/sites-available/*
sed -i "s/::HTTPS_PORT::/$HTTPS_PORT/g" /etc/apache2/sites-available/*

cert_dir=/etc/letsencrypt/live/$VIRTUAL_HOST
# if $cert_dir is empty or does not exist
if ! [ "$(ls -A $cert_dir 2> /dev/null)" ]; then
    echo "No SSL certificate found in /etc/letsencrypt/. Generating self-signed..."
    mkdir -p $cert_dir
    cd $cert_dir
    subject="/C=NL/ST=Amsterdam/O=Geant/localityName=Amsterdam/commonName=$VIRTUAL_HOST/organizationalUnitName=/emailAddress=/"
    openssl genrsa -out privkey.pem 2048
    openssl req -new -subj $subject -key privkey.pem -out csr
    openssl x509 -req -days 1000 -in csr -signkey privkey.pem -out cert.pem
    echo " " > /etc/letsencrypt/live/$VIRTUAL_HOST/chain.pem
fi


# start all the services
/usr/bin/supervisord -n -c /etc/supervisord.conf
