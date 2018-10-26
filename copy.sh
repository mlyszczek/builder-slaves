#!/bin/sh

cp -n *.opk /var/www/kurwinet.pl/opkg
cd /var/www/kurwinet.pl/opkg
./update.sh
chmod 440 *.opk
