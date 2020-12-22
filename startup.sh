#!/bin/bash
echo "SSLProxyEngine on" >> /usr/local/apache2/conf/httpd.conf
echo "ProxyPass /api $API_URL/api retry=0" >> /usr/local/apache2/conf/httpd.conf
echo "ProxyPass /apiaudit $API_URL/apiaudit retry=0" >> /usr/local/apache2/conf/httpd.conf
httpd-foreground