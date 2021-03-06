#!/bin/bash

cd /cprocsp-install/linux-amd64_deb && dpkg -i ./lsb-cprocsp-kc2-*

/opt/cprocsp/bin/amd64/certmgr -inst -store uMy -cont '\\.\HDIMAGE\localhost.test.gosuslugi.ru' -provtype 81 -provname "Crypto-Pro GOST R 34.10-2012 KC2 Strong CSP"
/opt/cprocsp/bin/amd64/certmgr -export -cert -dn "CN=localhost.test.gosuslugi.ru" -dest /etc/ssl/certs/srvtlsGost.cer
openssl x509 -inform DER -in /etc/ssl/certs/srvtlsGost.cer -out /etc/ssl/certs/srvtlsGost.pem

/usr/sbin/nginx -g 'daemon off;'

