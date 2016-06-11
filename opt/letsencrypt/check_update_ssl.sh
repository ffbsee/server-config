#!/bin/sh
service lighttpd stop
    if ! /opt/letsencrypt/letsencrypt-auto --email kommunikation@ffbsee.de --agree-tos --server https://acme-v01.api.letsencrypt.org/directory auth --quiet --standalone --expand --keep-until-expiring -d $(hostname) > /var/log/letsencrypt/renew.log 2>&1 ; then
    echo Automated renewal failed:
    cat /var/log/letsencrypt/renew.log
    exit 1
fi
cat /etc/letsencrypt/live/$(hostname)/privkey.pem /etc/letsencrypt/live/$(hostname)/cert.pem > /etc/letsencrypt/live/$(hostname)/ssl.pem
service lighttpd start

